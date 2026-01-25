//
//  ProfileSettingViewModel.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI
import Combine
import Photos
import PhotosUI
import UIKit

@MainActor
final class ProfileSettingViewModel: ObservableObject {
    // MARK: - Constants
    let nicknameMaxCount: Int = 20
    let introMaxCount: Int = 20

    // MARK: - Dependencies
    private let navigationRouter: NavigationRouter
    private let updateProfileUseCase: UpdateProfileUseCase
    private let profileRepository: ProfileRepository

    // MARK: - Published Properties
    @Published var nickname: String = "" {
        didSet {
            if nickname.count > nicknameMaxCount {
                let trimmed = String(nickname.prefix(nicknameMaxCount))
                if trimmed != nickname {
                    nickname = trimmed
                    return
                }
            }

            if nickname != oldValue {
                if nicknameCheckStatus == .available || nicknameCheckStatus == .duplicated {
                    nicknameCheckStatus = .none
                }
            }

            updateCanComplete()
        }
    }

    @Published var intro: String = "" {
        didSet {
            if intro.count > introMaxCount {
                let trimmed = String(intro.prefix(introMaxCount))
                if trimmed != intro {
                    intro = trimmed
                    return
                }
            }

            updateCanComplete()
        }
    }

    @Published var isPublic: Bool = true

    @Published var nicknameCheckStatus: NicknameCheckStatus = .none {
        didSet {
            updateCanComplete()
        }
    }

    @Published var pickedProfileImage: Image? = nil
    @Published var selectedPhotoPickerItem: PhotosPickerItem? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentProfileImageUrl: String? = nil

    @Published private(set) var canComplete: Bool = false
    @Published var isLoadingProfile: Bool = false

    private var selectedImageData: Data? = nil

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, updateProfileUseCase: UpdateProfileUseCase, profileRepository: ProfileRepository) {
        self.navigationRouter = navigationRouter
        self.updateProfileUseCase = updateProfileUseCase
        self.profileRepository = profileRepository
        updateCanComplete()
    }

    enum NicknameCheckStatus: Equatable {
        case none
        case checking
        case available
        case duplicated
    }

    var nicknameErrorText: String? {
        if nickname.isEmpty { return nil }
        if nickname.count > nicknameMaxCount { return "\(nicknameMaxCount)글자 이내로 입력해주세요" }
        if nicknameCheckStatus == .duplicated { return "이미 사용중인 아이디입니다." }
        return nil
    }

    var nicknameFilledHelper: String? {
        if nickname.isEmpty { return nil }
        if nicknameErrorText != nil { return nil }

        switch nicknameCheckStatus {
        case .none:
            return nil
        case .checking:
            return "확인 중이에요"
        case .available:
            return "사용 가능한 닉네임 입니다."
        case .duplicated:
            return nil
        }
    }

    var canTryNicknameCheck: Bool {
        if nickname.isEmpty { return false }
        if nicknameErrorText != nil { return false }
        if nicknameCheckStatus == .checking { return false }
        return true
    }

    var introErrorText: String? {
        return nil
    }

    // MARK: - Private Methods

    private func updateCanComplete() {
        let isNicknameValid = !nickname.isEmpty && nickname.count <= nicknameMaxCount
        let isNicknameChecked = nicknameCheckStatus == .available
        let isIntroValid = intro.count <= introMaxCount

        canComplete = isNicknameValid && isNicknameChecked && isIntroValid
    }

    func runNicknameDuplicateCheck() {
        nicknameCheckStatus = .checking

        Task {
            do {
                let isDuplicated = try await profileRepository.checkNicknameDuplicate(nickname: nickname)
                DispatchQueue.main.async {
                    self.nicknameCheckStatus = isDuplicated ? .duplicated : .available
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "닉네임 중복확인 실패: \(error.localizedDescription)"
                    self.nicknameCheckStatus = .none
                }
            }
        }
    }

    func loadCurrentProfile() async {
        isLoadingProfile = true

        do {
            let profileInfo = try await profileRepository.fetchMyProfile()
            DispatchQueue.main.async {
                self.nickname = profileInfo.nickname
                self.intro = profileInfo.introduction ?? ""
                self.isPublic = true // API에서 공개여부 정보가 있으면 적용
                self.nicknameCheckStatus = .available

                // 프로필 이미지 URL 저장 (null이면 기본 이미지 사용)
                self.currentProfileImageUrl = profileInfo.profileImageUrl

                self.updateCanComplete()
                self.isLoadingProfile = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "프로필 정보 로드 실패: \(error.localizedDescription)"
                self.isLoadingProfile = false
            }
        }
    }

    func onProfileImageTapped() {
        requestPhotoLibraryAccess()
    }

    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self?.selectedPhotoPickerItem = nil
                case .denied, .restricted:
                    self?.openAppSettings()
                case .notDetermined:
                    break
                @unknown default:
                    break
                }
            }
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    func handlePhotoSelection(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                // 선택한 이미지 미리보기 표시
                if let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.selectedImageData = data
                        self.pickedProfileImage = Image(uiImage: uiImage)
                        self.errorMessage = nil
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "이미지 선택 실패: \(error.localizedDescription)"
            }
        }
    }

    func onCompleteTapped() {
        Task {
            await submitProfileUpdate()
        }
    }

    private func submitProfileUpdate() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let _ = try await updateProfileUseCase.execute(
                nickname: nickname,
                bio: intro,
                isPublic: isPublic,
                imageData: selectedImageData
            )

            DispatchQueue.main.async {
                self.navigationRouter.navigateBack()
            }
        } catch {
            errorMessage = "프로필 수정 실패: \(error.localizedDescription)"
        }
    }
}
