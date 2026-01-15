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
        }
    }

    @Published var intro: String = "" {
        didSet {
            // 20자 제한 처리
            if intro.count > introMaxCount {
                let trimmed = String(intro.prefix(introMaxCount))
                // 무한 루프 방지: 값이 실제로 변경된 경우에만 업데이트
                if trimmed != intro {
                    intro = trimmed
                    return // didSet이 다시 호출되므로 여기서 종료
                }
            }
            // 닉네임 중복확인이 완료된 경우에는 canComplete를 절대 변경하지 않음
            // 한줄소개는 선택사항이므로 닉네임 중복확인 완료 후에는 영향 없음
        }
    }

    @Published var isPublic: Bool = true
    @Published var nicknameCheckStatus: NicknameCheckStatus = .none
    @Published var pickedProfileImage: Image? = nil
    
    // 닉네임 중복확인이 완료된 경우에는 항상 true를 반환
    var canComplete: Bool {
        // 닉네임은 필수이므로 비어있으면 비활성화
        if nickname.isEmpty {
            return false
        }
        // 닉네임 길이 에러가 있으면 비활성화
        if nickname.count > nicknameMaxCount {
            return false
        }
        // 닉네임 중복확인이 완료되지 않았으면 비활성화
        if nicknameCheckStatus != .available {
            return false
        }
        // 닉네임 중복확인이 완료된 경우에는 항상 활성화
        // (한줄소개는 선택사항이고, 20자 제한은 입력 단계에서 처리됨)
        return true
    }

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
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
        // 20자 제한은 입력 단계에서 처리되므로 에러 메시지 불필요
        return nil
    }

    // MARK: - Private Methods
    // canComplete는 computed property로 변경되어 더 이상 필요 없음

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
        // TODO: 실제 API 호출로 프로필 업데이트
        // 성공 후 이전 화면으로 돌아가기
        navigationRouter.navigateBack()
    }
}
