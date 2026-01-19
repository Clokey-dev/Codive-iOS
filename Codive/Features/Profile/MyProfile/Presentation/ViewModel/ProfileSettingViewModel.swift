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

    @Published private(set) var canComplete: Bool = false

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let lowered = self.nickname.lowercased()
            if lowered == "trendbox" || lowered == "ckj11" {
                self.nicknameCheckStatus = .duplicated
            } else {
                self.nicknameCheckStatus = .available
            }
        }
    }

    func onProfileImageTapped() {
        print("Profile image tapped")
    }

    func onCompleteTapped() {
        navigationRouter.navigateBack()
    }
}
