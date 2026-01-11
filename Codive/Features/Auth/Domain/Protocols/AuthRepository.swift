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
    func saveTokens(accessToken: String, refreshToken: String) async throws
}
