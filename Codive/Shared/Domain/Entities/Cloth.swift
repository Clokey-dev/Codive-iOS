//
//  Cloth.swift
//  Codive
//
//  Created by 황상환 on 11/25/25.
//

import Foundation

public struct Cloth: Identifiable, Codable, Equatable {
    
    public let id: Int
    public let imageUrl: String
    public let name: String?
    public let brand: String?
    public let purchaseUrl: String?
    public let categoryId: Int?
    public let season: Season?
    
    public init(
        id: Int,
        imageUrl: String,
        name: String? = nil,
        brand: String? = nil,
        purchaseUrl: String? = nil,
        categoryId: Int? = nil,
        season: Season? = nil
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.name = name
        self.brand = brand
        self.purchaseUrl = purchaseUrl
        self.categoryId = categoryId
        self.season = season
    }
}

public enum Season: String, Codable, CaseIterable, Identifiable {
    case spring = "SPRING"
    case summer = "SUMMER"
    case fall = "FALL"
    case winter = "WINTER"
    
    public var id: String { self.rawValue }
}
