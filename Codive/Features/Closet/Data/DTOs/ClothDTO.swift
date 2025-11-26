//
//  ClothDTO.swift
//  Codive
//
//  Created by Claude on 11/26/25.
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
    let categoryId: Int?
    let season: String?

    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl = "image_url"
        case name
        case brand
        case purchaseUrl = "purchase_url"
        case categoryId = "category_id"
        case season
    }

    /// DTO → Entity 변환
    func toEntity() -> Cloth {
        return Cloth(
            id: id,
            imageUrl: imageUrl,
            name: name,
            brand: brand,
            purchaseUrl: purchaseUrl,
            categoryId: categoryId,
            season: season != nil ? Season(rawValue: season!) : nil
        )
    }
}
