//
//  LookBookEntity.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import Foundation

// 룩북 전체 조회 api의 responseDTO의 content
struct LookBookEntity: Identifiable {
    let lookBookId: Int64
    var lookbookName: String
    let imageUrl: String
    let count: Int64

    var id: Int64 { lookBookId }
}

// 개별 룩북 코디 목록 조회 api의 responseDTO의 content
struct SpecificLookBookCodiEntity: Identifiable {
    let coordinateId: Int64
    let coordinateName: String
    let coordinateLiked: Bool
    let imageUrl: String

    var id: Int64 { coordinateId }
}

// 과거 일일 코디 조회 api responseDTO의 content
struct BeforeCoordinateDailyEntity: Identifiable {
    let coordinateId: Int64
    let imageUrl: String
    let date: String
    
    var id: Int64 { coordinateId }
}

struct CodiLikeEntity {
    let coordinateId: Int
}

struct DeleteCodiEntity {
    let coordinateId: Int
}

struct CoordinatePreviewEntity {
    let coordinateId: Int
    let imageUrl: String
    let coordinateName: String
    let coordinateMemo: String
}

// MARK: - Supporting Types
struct SelectedCodiData: Hashable {
    let imageURL: String
    let name: String
    let memo: String
}

struct CodiItem: Identifiable {
    let id: Int
    let imageName: String
    let brand: String
    let name: String
}

struct SelectedCodi: Hashable {
    let codiId: Int?
    let imageURL: String?
    let name: String
    let memo: String
    var combinedItems: [DraggableImageEntity]?
    
    init(
        codiId: Int?,      
        imageURL: String?,
        name: String,
        memo: String,
        combinedItems: [DraggableImageEntity]? = nil
    ) {
        self.codiId = codiId
        self.imageURL = imageURL
        self.name = name
        self.memo = memo
        self.combinedItems = combinedItems
    }
}
