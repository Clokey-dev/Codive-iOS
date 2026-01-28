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
