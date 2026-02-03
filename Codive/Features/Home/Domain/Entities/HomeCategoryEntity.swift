//
//  HomeCategoryEntity.swift
//  Codive
//
//  Created by 한금준 on 1/21/26.
//

// MARK: - Category
struct CategoryEntity: Identifiable, Codable {
    let id: Int
    let title: String
    var itemCount: Int
}

// MARK: - Home Cloth
struct HomeClothEntity {
    let clothId: Int64
    let imageUrl: String

    public init(
        clothId: Int64,
        imageUrl: String,
    ) {
        self.clothId = clothId
        self.imageUrl = imageUrl
    }
}
