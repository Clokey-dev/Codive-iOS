//
//  SituationConstants.swift
//  Codive
//
//  Created by 황상환 on 1/13/26.
//

import Foundation

// MARK: - Situation Item

struct SituationItem: Identifiable, Hashable {
    let id: Int64
    let name: String

    var situationId: Int64 { id }
}

// MARK: - Situation Constants

enum SituationConstants {

    static let all: [SituationItem] = [
        SituationItem(id: 1, name: "데일리"),
        SituationItem(id: 2, name: "여행"),
        SituationItem(id: 3, name: "데이트"),
        SituationItem(id: 4, name: "파티"),
        SituationItem(id: 5, name: "출근룩"),
        SituationItem(id: 6, name: "운동"),
        SituationItem(id: 7, name: "축제")
    ]

    /// 이름으로 SituationItem 찾기
    static func find(byName name: String) -> SituationItem? {
        all.first { $0.name == name }
    }

    /// ID로 SituationItem 찾기
    static func find(byId id: Int64) -> SituationItem? {
        all.first { $0.id == id }
    }

    /// 이름으로 ID 가져오기
    static func getId(from name: String) -> Int64? {
        find(byName: name)?.id
    }

    /// 이름 Set에서 첫 번째 ID 가져오기
    static func getFirstId(from names: Set<String>) -> Int64? {
        names.compactMap { find(byName: $0)?.id }.first
    }
}
