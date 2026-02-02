//
//  LookBookEntity.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import Foundation

// 룩북 조회
struct LookBookEntity: Identifiable {
    let lookBookId: Int64
    var lookbookName: String
    let imageUrl: String
    let count: Int64

    var id: Int64 { lookBookId }
}

// 특정 룩북의 코디 목록 조회
struct SpecificLookBookCodiEntity: Identifiable {
    let coordinateId: Int64
    let coordinateName: String
    var coordinateLiked: Bool
    let imageUrl: String

    var id: Int64 { coordinateId }
}

/// 과거 일일 코디 조회
struct BeforeCoordinateDailyEntity: Identifiable {
    let coordinateId: Int64
    let imageUrl: String
    let date: String
    
    var id: Int64 { coordinateId }
}

/// 코디 preview 조회
struct CoordinatePreviewEntity {
    let coordinateId: Int
    let imageUrl: String
    let coordinateName: String
    let coordinateMemo: String
}

/// 코디 detail 조회
struct CoordinateDetailEntity {
    let coordinateClothId: Int64
    let locationX: Double
    let locationY: Double
    let ratio: Double
    let degree: Double
    let order: Int32
    let imageUrl: String
    let brand: String
    let name: String
    let category: String
    let parentCategory: String
}

/// 오늘의 코디 옷 정보 조회
struct TodayCoordinateClothEntity {
    let imageUrl: String
    let brand: String
    let name: String
    let category: String
    let parentCategory: String
}

/// 코디 수동 생성
struct ManualCoordinateEntity {
    let coordinateId: Int64
}

/// 이전 일일 코디로 자동 생성
struct AutoDailyCoordinateEntity {
    let coordinateId: Int64
}

struct CodiLikeEntity {
    var coordinateId: Int
}

struct DeleteCodiEntity {
    let coordinateId: Int
}

// MARK: - Supporting Types
struct SelectedCodiData: Hashable {
    let imageURL: String
    let name: String
    let memo: String
}

struct CodiItem: Identifiable {
    let id: Int64
    let imageName: String
    let brand: String
    let name: String
}

struct SelectedCodi: Hashable {
    let coordinateId: Int64?
    let imageUrl: String?
    let name: String
    let memo: String
    var payloads: [Payloads]?
    
    init(
        coordinateId: Int64?,
        imageUrl: String?,
        name: String,
        memo: String,
        payloads: [Payloads]? = nil
    ) {
        self.coordinateId = coordinateId
        self.imageUrl = imageUrl
        self.name = name
        self.memo = memo
        self.payloads = payloads
    }
}

struct CodiTransferData {
    let payloads: [Payloads]
    let imageString: String
}

// 편집 모드용 데이터 (새로 추가)
struct CodiEditData {
    let payloads: [Payloads]
    let imageURL: String
    let codiName: String
    let memo: String
}
