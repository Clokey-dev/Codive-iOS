//
//  KeychainTokenProvider.swift
//  Codive
//
//  Created by 황상환 on 1/4/26.
//

import Foundation
import CodiveAPI

// MARK: - Keychain Token Provider
final class KeychainTokenProvider: TokenProvider {

    func getValidToken() async -> String? {
        do {
            let token = try KeychainManager.shared.getAccessToken()
            return token
        } catch {
            print("토큰 조회 실패: \(error)")
            return nil
        }
    }
}
