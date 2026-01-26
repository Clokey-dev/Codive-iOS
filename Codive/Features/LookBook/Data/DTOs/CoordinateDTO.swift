//
//  CoordinateDTO.swift
//  Codive
//
//  Created by 한금준 on 1/26/26.
//

import Foundation

struct CoordinatePreviewResponseDTO {
    let coordinateId: Int64
    let imageUrl: String
    let coordinateName: String
    let coordinateMemo: String
}

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


struct CreateAutoDailyCoordinateAPIRequestDTO {
    let name : String
    let memo : String
    let dailyCoordinateId : Int64
    let lookBookId : Int64
}

struct CreateAutoDailyCoordinateAPIResponseDTO {
    let coordinateId: Int64
}

struct GetTodayCoordinateClothResponseDTO {
    let imageUrl: String
    let brand: String
    let name: String
    let category: String
    let parentCategory: String
}
