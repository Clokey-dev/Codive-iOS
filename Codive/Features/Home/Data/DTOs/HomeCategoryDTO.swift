//
//  HomeCategoryDTO.swift
//  Codive
//
//  Created by 한금준 on 1/21/26.
//

import Foundation

struct HomeCategoryResponseDTO {
    let content: [HomeCategoryResponseItem]
    let isLast: Bool
}

struct HomeCategoryResponseItem {
    let clothId: Int64
    let ImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case clothId
        case ImageUrl
    }
    
    func toEntity(categoryId: Int64) -> HomeClothEntity {
        return HomeClothEntity(
            clothId: clothId,
            imageUrl: ImageUrl,
            categoryId: Int(categoryId)
        )
    }
}
