//
//  ClothTag.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation
import CoreGraphics

// MARK: - ClothTag
struct ClothTag: Identifiable, Equatable, Hashable {
    let id: UUID
    let clothId: Int
    let brand: String
    let name: String
    let imageUrl: String?
    let mainCategory: String?
    let subCategory: String?
    var locationX: CGFloat
    var locationY: CGFloat

    init(
        id: UUID,
        clothId: Int,
        brand: String,
        name: String,
        imageUrl: String?,
        mainCategory: String? = nil,
        subCategory: String? = nil,
        locationX: CGFloat,
        locationY: CGFloat
    ) {
        self.id = id
        self.clothId = clothId
        self.brand = brand
        self.name = name
        self.imageUrl = imageUrl
        self.mainCategory = mainCategory
        self.subCategory = subCategory
        self.locationX = locationX
        self.locationY = locationY
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ClothTag, rhs: ClothTag) -> Bool {
        lhs.id == rhs.id
    }

    /// 태그 타이틀 표시용 (브랜드 있으면 브랜드, 없으면 "No brand")
    var displayBrand: String {
        brand.isEmpty ? "No brand" : brand
    }

    /// 태그 내용 표시용 (이름 있으면 이름, 없으면 카테고리)
    var displayName: String {
        if !name.isEmpty {
            return name
        }
        if let main = mainCategory, let sub = subCategory {
            return "\(main) > \(sub)"
        } else if let main = mainCategory {
            return main
        }
        return ""
    }
}
