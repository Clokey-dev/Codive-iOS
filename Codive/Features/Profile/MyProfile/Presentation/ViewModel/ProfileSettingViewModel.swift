//
//  ProfileSettingViewModel.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI
import Combine

@MainActor
final class ProfileSettingViewModel: ObservableObject {
    // MARK: - Constants
    let nicknameMaxCount: Int = 20
    let introMaxCount: Int = 20

    // MARK: - Dependencies
    private let navigationRouter: NavigationRouter

    // MARK: - Published Properties
    @Published var nickname: String = "" {
        didSet {
            if nickname.count > nicknameMaxCount {
                nickname = String(nickname.prefix(nicknameMaxCount))
            }
            if nicknameCheckStatus == .available || nicknameCheckStatus == .duplicated {
                nicknameCheckStatus = .none
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
    @Published var pickedProfileImage: Image? = nil
    @Published var canComplete: Bool = false

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
        // 초기 상태 업데이트
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
            return nil // 에러 메시지로 표시되므로 여기서는 nil
        }
    }

    var canTryNicknameCheck: Bool {
        if nickname.isEmpty { return false }
        if nicknameErrorText != nil { return false }
        if nicknameCheckStatus == .checking { return false }
        return true
    }

    var introErrorText: String? {
        if intro.isEmpty { return nil }
        if intro.count > introMaxCount { return "20자 이내로 입력해주세요." }
        return nil
    }

    // MARK: - Public Methods
    func updateCanCompleteOnFocusChange() {
        // 포커스 변경 시에도 업데이트 (View에서 호출)
        updateCanComplete()
    }
    
    // MARK: - Private Methods
    private func updateCanComplete() {
        // 닉네임은 필수이므로 비어있으면 비활성화
        if nickname.isEmpty {
            canComplete = false
            return
        }
        // 닉네임 길이 에러가 있으면 비활성화 (중복 에러는 제외)
        if nickname.count > nicknameMaxCount {
            canComplete = false
            return
        }
        // 닉네임 중복확인이 완료되지 않았으면 비활성화
        if nicknameCheckStatus != .available {
            canComplete = false
            return
        }
        // 닉네임 중복확인이 완료된 상태에서, 한줄소개가 20자 초과면 비활성화
        if intro.count > introMaxCount {
            canComplete = false
            return
        }
        canComplete = true
    }

    func runNicknameDuplicateCheck() {
        nicknameCheckStatus = .checking

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let lowered = self.nickname.lowercased()
            if lowered == "trendbox" || lowered == "ckj11" {
                self.nicknameCheckStatus = .duplicated
            } else {
                self.nicknameCheckStatus = .available
            }
            // 명시적으로 업데이트 호출 (didSet이 호출되지만 확실하게)
            self.updateCanComplete()
        }
    }

    func onProfileImageTapped() {
        print("Profile image tapped")
    }

    func onCompleteTapped() {
        // TODO: 실제 API 호출로 프로필 업데이트
        // 성공 후 이전 화면으로 돌아가기
        navigationRouter.navigateBack()
    }
}
