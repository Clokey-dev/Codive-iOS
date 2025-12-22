//
//  WardrobeStatistics.swift
//  Codive
//
//  Created by Codive on 12/23/25.
//

import SwiftUI

struct CategoryFavoriteItem: Identifiable, Hashable {
    let id = UUID()
    let categoryName: String
    let items: [DonutSegment]
}

struct ItemUsageStat: Identifiable, Hashable {
    let id = UUID()
    let itemName: String
    let usageCount: Int
}

struct WardrobeUsageStat: Hashable {
    let totalCount: Int
    let wornCount: Int
    
    var usagePercent: Int {
        guard totalCount > 0 else { return 0 }
        return Int(round((Double(wornCount) / Double(totalCount)) * 100))
    }
}
