//
//  WardrobeStatistics.swift
//  Codive
//
//  Created by Codive on 12/23/25.
//

import SwiftUI

struct CategoryFavoriteItem: Identifiable, Hashable {
    let id = UUID()
    let parentCategoryId: Int64
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

struct ClothItem: Identifiable, Hashable {
    let id: UUID = .init()
    let imageUrl: String
    let brand: String
    let name: String

    init(imageUrl: String, brand: String, name: String) {
        self.imageUrl = imageUrl
        self.brand = brand
        self.name = name
    }

    /// `Cloth` 엔티티로부터 매핑. brand/name이 비어 있으면 카테고리로 fallback.
    init(from cloth: Cloth) {
        self.imageUrl = cloth.imageUrl
        self.brand = cloth.brand?.trimmingCharacters(in: .whitespaces) ?? ""

        if let name = cloth.name?.trimmingCharacters(in: .whitespaces), !name.isEmpty {
            self.name = name
        } else if let sub = cloth.subCategory, !sub.isEmpty {
            self.name = sub
        } else if let main = cloth.mainCategory, !main.isEmpty {
            self.name = main
        } else {
            self.name = ""
        }
    }
}
