//
//  LookBookDTO.swift
//  Codive
//
//  Created by 한금준 on 1/22/26.
//

import Foundation

/// 룩북 전체 조회
struct LookBookListResponseDTO {
    let content: [LookBookListResponseItem]
    let isLast: Bool
}

struct LookBookListResponseItem {
    let lookBookId: Int64
    let lookBookName: String
    let imageUrl: String
//    let count: Int64
    
    enum CodingKeys: String, CodingKey {
        case lookBookId
        case lookBookName
        case ImageUrl
//        case count
    }
    
    func toEntity() -> LookBookEntity {
        return LookBookEntity(
            lookBookId: lookBookId,
            lookbookName: lookBookName,
            imageUrl: imageUrl,
//            count: count
            count: 0
        )
    }
}

struct CreateLookBookAPIRequestDTO {
    let name: String
}

struct CreateLookBookResponseDTO {
    let lookBookId: Int64
}

struct UpdateLookBookAPIRequestDTO {
    let name: String
}
