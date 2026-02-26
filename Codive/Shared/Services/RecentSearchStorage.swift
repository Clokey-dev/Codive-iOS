//
//  RecentSearchStorage.swift
//  Codive
//
//  Created on 2/26/26.
//

import Foundation

enum RecentSearchItem: Codable, Hashable {
    case keyword(String)
    case member(userId: String, nickname: String, profileImageUrl: String?)

    var id: String {
        switch self {
        case .keyword(let text):
            return "keyword:\(text)"
        case .member(let userId, _, _):
            return "member:\(userId)"
        }
    }
}

extension RecentSearchItem {
    func toSearchResultType() -> SearchResultType {
        switch self {
        case .keyword(let text):
            return .hashTag(title: text)
        case .member(_, let nickname, let profileImageUrl):
            return .member(
                imageUrl: profileImageUrl ?? "",
                title: nickname,
                subtitle: ""
            )
        }
    }
}

enum RecentSearchStorage {
    private static let key = "RecentSearchItems"
    private static let maxCount = 20

    static func save(_ items: [RecentSearchItem]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> [RecentSearchItem] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([RecentSearchItem].self, from: data)) ?? []
    }

    static func addTerm(_ term: String) {
        addItem(.keyword(term))
    }

    static func addMember(userId: String, nickname: String, profileImageUrl: String?) {
        addItem(.member(userId: userId, nickname: nickname, profileImageUrl: profileImageUrl))
    }

    static func addItem(_ item: RecentSearchItem) {
        var items = load()
        items.removeAll { $0.id == item.id }
        items.insert(item, at: 0)
        if items.count > maxCount {
            items = Array(items.prefix(maxCount))
        }
        save(items)
    }

    static func removeItem(_ item: RecentSearchItem) {
        var items = load()
        items.removeAll { $0.id == item.id }
        save(items)
    }

    static func removeTerm(_ term: String) {
        removeItem(.keyword(term))
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
