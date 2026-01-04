//
//  AuthRepository.swift
//  Codive
//
//  Created by 황상환 on 9/24/25.
//

import Foundation

// MARK: - Auth Repository Protocol
protocol AuthRepository {
    func socialLogin(provider: AuthProvider) async -> AuthResult
    func checkAuthStatus() async -> AuthStatusResult
    func logout() async

    // 향후 서버 연결 시 추가될 메서드들
    // func refreshToken() async -> AuthResult
    // func deleteAccount() async -> Bool
}
