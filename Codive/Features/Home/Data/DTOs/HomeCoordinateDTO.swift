//
//  HomeCoordinateDTO.swift
//  Codive
//
//  Created by 한금준 on 1/26/26.
//

import Foundation

struct CreateTodayCoordinateRequestDTO {
    let coordinateImageUrl: String
    let payloads: [Payloads]
}

struct CreateTodayCoordinateResponseDTO {
    let coordinateId: Int64
}
