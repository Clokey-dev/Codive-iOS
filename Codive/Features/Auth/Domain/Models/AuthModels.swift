//
//  AuthModels.swift
//  Codive
//
//  Created by 황상환 on 9/24/25.
//

import Foundation

// MARK: - Auth Result
enum AuthResult {
    case success(AuthUser)
    case failure(AuthError)
}

// MARK: - Auth User
struct AuthUser {
    let id: String
    let email: String?
    let name: String?
    let provider: AuthProvider
}

// MARK: - Auth Provider
enum AuthProvider: String {
    case kakao
    case apple
    
    var displayName: String {
        switch self {
        case .kakao:
            return "카카오"
        case .apple:
            return "애플"
        }
    }
}

// MARK: - Auth Error
enum AuthError: Error, LocalizedError {
    case cancelled
    case networkError(String)
    case userInfoError
    case unknown(String)
    case tokenParsingError
    case keychainError(String)

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "사용자가 로그인을 취소했습니다"
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        case .userInfoError:
            return "사용자 정보를 가져오는데 실패했습니다"
        case .unknown(let message):
            return "알 수 없는 오류: \(message)"
        case .tokenParsingError:
            return "토큰 파싱 오류"
        case .keychainError(let message):
            return "토큰 저장 오류: \(message)"
        }
    }
}

// MARK: - Auth Token Response (서버 응답)
struct AuthTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

// MARK: - Register Status
enum RegisterStatus {
    case notAgreed  // 약관 동의 필요
    case registered // 약관 동의 완료
}
