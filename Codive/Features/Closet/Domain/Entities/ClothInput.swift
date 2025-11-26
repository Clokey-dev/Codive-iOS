//
//  ClothInput.swift
//  Codive
//
//  Created by 황상환 on 11/26/25.
//

import Foundation

/// 옷 추가를 위한 입력 데이터
public struct ClothInput {
    public let name: String
    public let brand: String
    public let purchaseUrl: String
    public let categoryId: Int?
    public let seasons: Set<Season>

    public init(
        name: String,
        brand: String,
        purchaseUrl: String,
        categoryId: Int?,
        seasons: Set<Season>
    ) {
        self.name = name
        self.brand = brand
        self.purchaseUrl = purchaseUrl
        self.categoryId = categoryId
        self.seasons = seasons
    }
}
