import Foundation
import Security

enum KeychainError: Error {
    case itemNotFound
    case duplicateItem
    case invalidData
    case unexpectedStatus(OSStatus)

    var localizedDescription: String {
        switch self {
        case .itemNotFound:
            return "토큰을 찾을 수 없습니다."
        case .duplicateItem:
            return "이미 존재하는 토큰입니다."
        case .invalidData:
            return "잘못된 데이터 형식입니다."
        case .unexpectedStatus(let status):
            return "Keychain 오류: \(status)"
        }
    }
}

final class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    private let accessTokenKey = "com.codive.accessToken"
    private let refreshTokenKey = "com.codive.refreshToken"

    // MARK: - Access Token

    func saveAccessToken(_ token: String) throws {
        try save(token, forKey: accessTokenKey)
        #if DEBUG
        print("----------------------------------------")
        print("[Keychain] Access Token Saved:")
        print(token)
        print("----------------------------------------")
        #endif
    }

    func getAccessToken() throws -> String {
        return try get(forKey: accessTokenKey)
    }

    func deleteAccessToken() throws {
        try delete(forKey: accessTokenKey)
    }

    // MARK: - Refresh Token

    func saveRefreshToken(_ token: String) throws {
        try save(token, forKey: refreshTokenKey)
    }

    func getRefreshToken() throws -> String {
        return try get(forKey: refreshTokenKey)
    }

    func deleteRefreshToken() throws {
        try delete(forKey: refreshTokenKey)
    }

    // MARK: - Clear All

    func clearAllTokens() throws {
        try? deleteAccessToken()
        try? deleteRefreshToken()
    }

    // MARK: - Private Methods

    private func save(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        // 기존 항목 삭제 (중복 방지)
        try? delete(forKey: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    private func get(forKey key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unexpectedStatus(status)
        }

        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return value
    }

    private func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
