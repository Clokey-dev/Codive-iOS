//
//  UserProfileStorage.swift
//  Codive
//
//  Created on 2/25/26.
//

import Foundation

enum UserProfileStorage {
    private static let key = "CachedMyProfileInfo"

    static func save(_ profile: MyProfileInfo) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> MyProfileInfo? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(MyProfileInfo.self, from: data)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
