//
//  ClothDTO.swift
//  Codive
//
//  Created by 황상환 on 11/26/25.
//

import Foundation

// MARK: - ClothRequestDTO
/// 옷 저장 요청 DTO
struct ClothRequestDTO: Encodable {
    let image: Data
    let name: String?
    let brand: String?
    let purchaseUrl: String?
    let categoryId: Int?
    let seasons: [String]

    enum CodingKeys: String, CodingKey {
        case image
        case name
        case brand
        case purchaseUrl = "purchase_url"
        case categoryId = "category_id"
        case seasons
    }
}

// MARK: - ClothResponseDTO
/// 옷 저장/조회 응답 DTO
struct ClothResponseDTO: Decodable {
    let id: Int
    let imageUrl: String
    let name: String?
    let brand: String?
    let purchaseUrl: String?
    let parentCategory: String?
    let category: String?
    let seasons: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl = "imageUrl"
        case name
        case brand
        case purchaseUrl = "purchase_url"
        case parentCategory = "parentCategory"
        case category = "category"
        case seasons
    }

    /// DTO → Entity 변환
    func toEntity() -> Cloth {
        let seasonSet = Set(seasons.compactMap { Season(rawValue: $0) })
        return Cloth(
            id: id,
            imageUrl: imageUrl,
            name: name,
            brand: brand,
            purchaseUrl: purchaseUrl,
            mainCategory: parentCategory,
            subCategory: category,
            seasons: seasonSet
        )
    }
}
