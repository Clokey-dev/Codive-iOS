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
    public let mainCategory: String?
    public let subCategory: String?
    public let seasons: Set<Season>

    public init(
        id: Int,
        imageUrl: String,
        name: String? = nil,
        brand: String? = nil,
        purchaseUrl: String? = nil,
        mainCategory: String? = nil,
        subCategory: String? = nil,
        seasons: Set<Season> = []
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.name = name
        self.brand = brand
        self.purchaseUrl = purchaseUrl
        self.mainCategory = mainCategory
        self.subCategory = subCategory
        self.seasons = seasons
    }
}

// MARK: - Display Properties Extension
extension Cloth {
    /// 이름이 없을 때 표시할 카테고리 문자열 (예: "상의 > 후드티")
    public var displayCategory: String {
        if let mainCategory = mainCategory, let subCategory = subCategory {
            return "\(mainCategory) > \(subCategory)"
        }
        return ""
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

    /// 현재 월 기준의 시즌 (3-5: 봄, 6-8: 여름, 9-11: 가을, 12-2: 겨울)
    public static var current: Season {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3, 4, 5: return .spring
        case 6, 7, 8: return .summer
        case 9, 10, 11: return .fall
        default: return .winter
        }
    }
}
