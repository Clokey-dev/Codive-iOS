//
//  ProductItem.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation

// MARK: - Product Item Model
struct ProductItem: Identifiable {
    let id: Int
    let imageName: String?
    let imageUrl: String?
    let isTodayCloth: Bool
    let brand: String?
    let name: String?

    init(
        id: Int,
        imageName: String? = nil,
        imageUrl: String? = nil,
        isTodayCloth: Bool = false,
        brand: String? = nil,
        name: String? = nil
    ) {
        self.id = id
        self.imageName = imageName
        self.imageUrl = imageUrl
        self.isTodayCloth = isTodayCloth
        self.brand = brand
        self.name = name
    }
}
