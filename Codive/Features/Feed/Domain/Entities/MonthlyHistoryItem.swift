//
//  MonthlyHistoryItem.swift
//  Codive
//
//  Created by 황상환 on 1/31/26.
//

import Foundation

// MARK: - Domain Entity
struct MonthlyHistoryItem {
    let historyId: Int64
    let firstImageUrl: String
    let historyDate: String // "2026-01-21" 형식
}

// MARK: - Data Transfer Object (DTO)
struct MonthlyHistoryItemDTO: Decodable {
    let historyId: Int64?
    let firstImageUrl: String?
    let historyDate: String?
}
