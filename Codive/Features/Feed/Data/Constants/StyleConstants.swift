//
//  StyleConstants.swift
//  Codive
//
//  Created by 황상환 on 1/13/26.
//

import Foundation

// MARK: - Style Item

struct StyleItem: Identifiable, Hashable {
    let id: Int64
    let name: String

    var styleId: Int64 { id }
}

// MARK: - Style Constants

enum StyleConstants {

    static let all: [StyleItem] = [
        StyleItem(id: 1, name: "캐주얼"),
        StyleItem(id: 2, name: "스트릿"),
        StyleItem(id: 3, name: "미니멀"),
        StyleItem(id: 4, name: "클래식"),
        StyleItem(id: 5, name: "시크"),
        StyleItem(id: 6, name: "빈티지"),
        StyleItem(id: 7, name: "걸리시"),
        StyleItem(id: 8, name: "스포티"),
        StyleItem(id: 9, name: "러블리"),
        StyleItem(id: 10, name: "오피스룩"),
        StyleItem(id: 11, name: "하이틴")
    ]

    /// 이름으로 StyleItem 찾기
    static func find(byName name: String) -> StyleItem? {
        all.first { $0.name == name }
    }

    /// ID로 StyleItem 찾기
    static func find(byId id: Int64) -> StyleItem? {
        all.first { $0.id == id }
    }

    /// 이름 배열로 ID 배열 변환
    static func getIds(from names: [String]) -> [Int64] {
        names.compactMap { find(byName: $0)?.id }
    }

    /// 이름 Set으로 ID 배열 변환
    static func getIds(from names: Set<String>) -> [Int64] {
        getIds(from: Array(names))
    }
}
