//
//  RecentSearchStorage.swift
//  Codive
//
//  Created on 2/26/26.
//

import Foundation

enum RecentSearchStorage {
    private static let key = "RecentSearchTerms"
    private static let maxCount = 20

    static func save(_ terms: [String]) {
        UserDefaults.standard.set(terms, forKey: key)
    }

    static func load() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    static func addTerm(_ term: String) {
        var terms = load()
        terms.removeAll { $0 == term }
        terms.insert(term, at: 0)
        if terms.count > maxCount {
            terms = Array(terms.prefix(maxCount))
        }
        save(terms)
    }

    static func removeTerm(_ term: String) {
        var terms = load()
        terms.removeAll { $0 == term }
        save(terms)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
