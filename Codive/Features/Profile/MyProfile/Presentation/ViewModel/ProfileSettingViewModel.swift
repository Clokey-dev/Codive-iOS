//
//  ProfileSettingViewModel.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI
import Combine

class ProfileSettingViewModel: ObservableObject {
    // MARK: - Constants
    let nicknameMaxCount: Int = 6
    let userIdMaxCount: Int = 20
    let introMaxCount: Int = 20
    
    // MARK: - Published Properties
    @Published var nickname: String = "" {
        didSet {
            if nickname.count > nicknameMaxCount {
                nickname = String(nickname.prefix(nicknameMaxCount))
            }
        }
    }
    
    @Published var userId: String = "" {
        didSet {
            if userId.count > userIdMaxCount {
                userId = String(userId.prefix(userIdMaxCount))
            }
            // Reset check status if user changes ID
            if idCheckStatus == .available || idCheckStatus == .duplicated {
                idCheckStatus = .none
            }
        }
    }
    
    @Published var intro: String = "" {
        didSet {
            if intro.count > introMaxCount {
                intro = String(intro.prefix(introMaxCount))
            }
        }
    }
    
    @Published var isPublic: Bool = true
    @Published var idCheckStatus: IDCheckStatus = .none
    @Published var pickedProfileImage: Image? = nil
    
    // MARK: - Types
    enum IDCheckStatus: Equatable {
        case none
        case checking
        case available
        case duplicated
    }
    
    // MARK: - Validation Helpers
    var nicknameErrorText: String? {
        if nickname.isEmpty { return nil }
        if nickname.count > nicknameMaxCount { return "\(nicknameMaxCount)글자 이내로 입력해주세요" }
        return nil
    }

    var nicknameFilledHelper: String? {
        if nickname.isEmpty { return nil }
        if nicknameErrorText != nil { return nil }
        return "사용 가능한 닉네임 입니다."
    }

    var canTryIDCheck: Bool {
        if userId.isEmpty { return false }
        if userId.count > userIdMaxCount { return false }
        if userIdErrorText != nil { return false }
        if idCheckStatus == .checking { return false }
        return true
    }

    var userIdErrorText: String? {
        if userId.isEmpty { return nil }
        if userId.count > userIdMaxCount { return "\(userIdMaxCount)자 이내로 입력해주세요" }
        if containsUppercase(userId) { return "대문자는 사용할 수 없어요" }
        if containsSpecialCharacters(userId) { return "특수문자는 사용할 수 없어요" }
        return nil
    }

    var userIdFilledHelper: String? {
        if userId.isEmpty { return nil }
        if userIdErrorText != nil { return nil }

        switch idCheckStatus {
        case .none:
            return nil
        case .checking:
            return "확인 중이에요"
        case .available:
            return "사용 가능한 아이디 입니다."
        case .duplicated:
            return nil
        }
    }

    var introErrorText: String? {
        if intro.isEmpty { return nil }
        if intro.count > introMaxCount { return "\(introMaxCount)자 이내로 입력해주세요" }
        return nil
    }

    var canComplete: Bool {
        if nickname.isEmpty { return false }
        if nicknameErrorText != nil { return false }

        if userId.isEmpty { return false }
        if userIdErrorText != nil { return false }
        if idCheckStatus != .available { return false }

        if introErrorText != nil { return false }
        return true
    }
    
    // MARK: - Actions
    func runIDDuplicateCheck() {
        idCheckStatus = .checking

        // Mock API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if self.userId.lowercased() == "trendbox" || self.userId.lowercased() == "ckj11" {
                self.idCheckStatus = .duplicated
            } else {
                self.idCheckStatus = .available
            }
        }
    }
    
    func onProfileImageTapped() {
        print("Profile image tapped")
    }
    
    func onCompleteTapped() {
        print("Complete tapped")
    }
    
    // MARK: - Private Helpers
    private func containsUppercase(_ s: String) -> Bool {
        s.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
    }

    private func containsSpecialCharacters(_ s: String) -> Bool {
        let allowed = CharacterSet.alphanumerics
        return s.rangeOfCharacter(from: allowed.inverted) != nil
    }
}
