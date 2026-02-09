//
//  HomeCoordinateDTO.swift
//  Codive
//
//  Created by 한금준 on 1/26/26.
//

import Foundation

/// 오늘의 코디 생성
struct CreateTodayCoordinateRequestDTO {
    let coordinateImageUrl: String
    let payloads: [Payloads]
}

/// 오늘의 코디 생성
struct CreateTodayCoordinateResponseDTO {
    let coordinateId: Int64
    
    func toEntity() -> TodayCoordinateEntity {
        TodayCoordinateEntity(coordinateId: coordinateId)
    }
}

struct FetchTodayCoordinatePreviewResponseDTO {
    let coordinateId: Int64
    let imageUrl: String
    let date: String
}

struct FetchTodayCoordinateDetailsResponseDTO {
    let coordinateClothId: Int64
    let locationX: Double
    let locationY: Double
    let ratio: Double
    let degree: Double
    let order: Int32
    let clothId: Int64
    let imageUrl: String
    let brand: String
    let name: String
    let category: String
    let parentCategory: String
}
