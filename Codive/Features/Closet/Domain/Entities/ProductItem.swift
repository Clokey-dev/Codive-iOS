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
    let mainCategory: String?
    let subCategory: String?

    init(
        id: Int,
        imageName: String? = nil,
        imageUrl: String? = nil,
        isTodayCloth: Bool = false,
        brand: String? = nil,
        name: String? = nil,
        mainCategory: String? = nil,
        subCategory: String? = nil
    ) {
        self.id = id
        self.imageName = imageName
        self.imageUrl = imageUrl
        self.isTodayCloth = isTodayCloth
        self.brand = brand
        self.name = name
        self.mainCategory = mainCategory
        self.subCategory = subCategory
    }

    /// 카테고리 표시 문자열 (예: "상의 > 니트/스웨터")
    var displayCategory: String {
        if let main = mainCategory, let sub = subCategory {
            return "\(main) > \(sub)"
        } else if let main = mainCategory {
            return main
        } else if let sub = subCategory {
            return sub
        }
        return ""
    }
}
