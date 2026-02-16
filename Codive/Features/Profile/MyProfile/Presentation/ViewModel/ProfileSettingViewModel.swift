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
            updateCanComplete()
        }
    }

    @Published var isPublic: Bool = true

    @Published var nicknameCheckStatus: NicknameCheckStatus = .none {
        didSet {
            updateCanComplete()
        }
    }

    @Published var pickedProfileImage: Image?
    @Published var selectedPhotoPickerItem: PhotosPickerItem?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentProfileImageUrl: String?

    @Published private(set) var canComplete: Bool = false
    @Published var isLoadingProfile: Bool = false

    private var selectedImageData: Data?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, updateProfileUseCase: UpdateProfileUseCase, profileRepository: ProfileRepository) {
        self.navigationRouter = navigationRouter
        self.updateProfileUseCase = updateProfileUseCase
        self.profileRepository = profileRepository
        updateCanComplete()
        setupTextLimits()
    }

    private func setupTextLimits() {
        $nickname
            .removeDuplicates()
            .filter { $0.count > self.nicknameMaxCount }
            .sink { [weak self] _ in
                guard let self else { return }
                self.nickname = String(self.nickname.prefix(self.nicknameMaxCount))
            }
            .store(in: &cancellables)

        $intro
            .removeDuplicates()
            .filter { $0.count > self.introMaxCount }
            .sink { [weak self] _ in
                guard let self else { return }
                self.intro = String(self.intro.prefix(self.introMaxCount))
            }
            .store(in: &cancellables)
    }

    enum NicknameCheckStatus: Equatable {
        case none
        case checking
        case available
        case duplicated
    }

    var nicknameErrorText: String? {
        if nickname.isEmpty { return nil }
        if nickname.count > nicknameMaxCount {
            return "20자 이내로 아이디를 입력해주세요."
        }
        if nicknameCheckStatus == .duplicated {
            return "이미 사용중인 아이디입니다."
        }

        let hasUppercase = nickname.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasInvalidSpecialChars = nickname.range(of: "[^a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ_.]", options: .regularExpression) != nil

        if hasUppercase && hasInvalidSpecialChars {
            return "숫자,소문자,한글, 밑줄 및 마침표로 작성해주세요."
        }
        if hasUppercase {
            return "대문자는 입력이 불가해요. 소문자로 작성해주세요."
        }
        if hasInvalidSpecialChars {
            return "문자는 밑줄 및 마침표만 사용할 수 있어요."
        }

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
        guard isNicknameRegexValid else { return false }
        guard nicknameCheckStatus != .checking else { return false }
        return true
    }

    var introErrorText: String? {
        if intro.isEmpty { return nil }
        if intro.count > introMaxCount {
            return "20자 이내로 입력해주세요."
        }
        return nil
    }

    // MARK: - Private Methods

    private var isNicknameRegexValid: Bool {
        guard !nickname.isEmpty else { return false }
        guard nickname.count <= nicknameMaxCount else { return false }
        let pattern = "^[a-z0-9가-힣ㄱ-ㅎㅏ-ㅣ_.]+$"
        return nickname.range(of: pattern, options: .regularExpression) != nil
    }

    private func updateCanComplete() {
        let isNicknameValid = isNicknameRegexValid
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
                self.isPublic = profileInfo.isPublic
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
            _ = try await updateProfileUseCase.execute(
                nickname: nickname,
                bio: intro,
                isPublic: isPublic,
                imageData: selectedImageData,
                currentImageUrl: currentProfileImageUrl
            )

            DispatchQueue.main.async {
                self.navigationRouter.navigateBack()
            }
        } catch {
            errorMessage = "프로필 수정 실패: \(error.localizedDescription)"
        }
    }
}
