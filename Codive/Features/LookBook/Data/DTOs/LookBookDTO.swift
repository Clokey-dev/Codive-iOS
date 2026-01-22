//
//  LookBookDTO.swift
//  Codive
//
//  Created by 한금준 on 1/22/26.
//

import Foundation

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
