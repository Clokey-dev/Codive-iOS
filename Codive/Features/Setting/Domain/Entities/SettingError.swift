//
//  SettingError.swift
//  Codive
//

import Foundation

enum SettingError: LocalizedError {
    case apiError(message: String)
    case decodingError(String)
    case networkError
    case invalidUserId
    case unknown

    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return message
        case .decodingError(let details):
            return "데이터 처리 오류: \(details)"
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .invalidUserId:
            return "잘못된 사용자 ID입니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .apiError:
            return "다시 시도해주세요."
        case .decodingError:
            return "앱을 다시 시작해주세요."
        case .networkError:
            return "네트워크 연결을 확인하고 다시 시도해주세요."
        case .invalidUserId:
            return "앱을 다시 시작해주세요."
        case .unknown:
            return "다시 시도해주세요."
        }
    }
}
