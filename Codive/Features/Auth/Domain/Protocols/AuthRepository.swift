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
    func checkAuthStatus() async throws -> RegisterStatus
    func logout() async
    func deactivateAccount() async throws
    func saveTokens(accessToken: String, refreshToken: String) async throws
}
