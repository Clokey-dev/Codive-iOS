//
//  CoordinateDTO.swift
//  Codive
//
//  Created by 한금준 on 1/26/26.
//

import Foundation

/// 코디 preview 조회
struct CoordinatePreviewResponseDTO {
    let coordinateId: Int64
    let imageUrl: String
    let coordinateName: String
    let coordinateMemo: String
    
    func toEntity() -> CoordinatePreviewEntity {
        return CoordinatePreviewEntity(
            coordinateId: Int(coordinateId),
            imageUrl: imageUrl,
            coordinateName: coordinateName,
            coordinateMemo: coordinateMemo
        )
    }
}

/// 코디 detail 조회
struct CoordinateDetailResponseDTO {
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
    
    func toEntity() -> CoordinateDetailEntity {
        CoordinateDetailEntity(
            coordinateClothId: coordinateClothId,
            locationX: locationX,
            locationY: locationY,
            ratio: ratio,
            degree: degree,
            order: order,
            imageUrl: imageUrl,
            brand: brand,
            name: name,
            category: category,
            parentCategory: parentCategory
        )
    }
}

struct CreateManualCoordinateAPIRequestDTO {
    let coordinateImageUrl: String
    let name: String
    let memo: String
    let lookBookId: Int64
    let payloads: [Payloads]
}

struct CreateManualCoordinateAPIResponseDTO {
    let coordinateId: Int64
    
    func toEntity() -> ManualCoordinateEntity {
        ManualCoordinateEntity(
            coordinateId: coordinateId
        )
    }
}

struct EditCoordinateRequestDTO {
    let coordinateImageUrl: String?
    let name: String?
    let memo: String?
    let payloads: [Payloads]?
}

struct Payloads {
    let clothId: Int64
    let locationX: Double
    let locationY: Double
    let ratio: Double
    let degree: Double
    let order: Int32
}

/// 이전 일일 코디로 자동 생성
struct CreateAutoDailyCoordinateAPIRequestDTO {
    let name : String
    let memo : String
    let dailyCoordinateId : Int64
    let lookBookId : Int64
}

/// 이전 일일 코디로 자동 생성
struct CreateAutoDailyCoordinateAPIResponseDTO {
    let coordinateId: Int64
    
    func toEntity() -> AutoDailyCoordinateEntity {
        AutoDailyCoordinateEntity(
            coordinateId: coordinateId
        )
    }
}

/// 오늘의 코디 옷 정보 조회
struct GetTodayCoordinateClothResponseDTO {
    let imageUrl: String
    let brand: String
    let name: String
    let category: String
    let parentCategory: String
    
    func toEntity() -> TodayCoordinateClothEntity {
        TodayCoordinateClothEntity(
            imageUrl: imageUrl,
            brand: brand,
            name: name,
            category: category,
            parentCategory: parentCategory
        )
    }
}
