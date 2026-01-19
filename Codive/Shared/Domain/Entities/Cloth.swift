//
//  Cloth.swift
//  Codive
//
//  Created by 황상환 on 11/25/25.
//

import Foundation

public struct Cloth: Identifiable, Equatable, Hashable {

    public let id: Int
    public let imageUrl: String
    public let name: String?
    public let brand: String?
    public let purchaseUrl: String?
    public let categoryId: Int?
    public let seasons: Set<Season>

    public init(
        id: Int,
        imageUrl: String,
        name: String? = nil,
        brand: String? = nil,
        purchaseUrl: String? = nil,
        categoryId: Int? = nil,
        seasons: Set<Season> = []
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.name = name
        self.brand = brand
        self.purchaseUrl = purchaseUrl
        self.categoryId = categoryId
        self.seasons = seasons
    }
}

public enum Season: String, CaseIterable, Identifiable {
    case spring = "SPRING"
    case summer = "SUMMER"
    case fall = "FALL"
    case winter = "WINTER"

    public var id: String { self.rawValue }

    public var displayName: String {
        switch self {
        case .spring:
            return "봄"
        case .summer:
            return "여름"
        case .fall:
            return "가을"
        case .winter:
            return "겨울"
        }
    }
}
