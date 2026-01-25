//
//  LookBookCoordinateDTO.swift
//  Codive
//
//  Created by 한금준 on 1/23/26.
//

import Foundation

/// 개별 룩북  코디 전체 조회
struct LookBookCoordinateResponseDTO {
    let content: [LookBookCoordinateListResponseItem]
    let isLast: Bool
}

struct LookBookCoordinateListResponseItem {
    let coordinateId: Int64
    let coordinateName: String
    let coordinateLiked: Bool
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case coordinateId
        case coordinateName
        case coordinateLiked
        case imageUrl
    }
    
    func toEntity() -> SpecificLookBookCodiEntity {
        return SpecificLookBookCodiEntity(
            coordinateId: coordinateId,
            coordinateName: coordinateName,
            coordinateLiked: coordinateLiked,
            imageUrl: imageUrl
        )
    }
}
