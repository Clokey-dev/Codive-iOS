//
//  HomeCodiEntity.swift
//  Codive
//
//  Created by 한금준 on 1/21/26.
//

import Foundation

/// 오늘의 코디 생성
struct TodayCoordinateEntity {
    let coordinateId: Int64
}

// MARK: - Codi Item
struct CodiItemEntity: Identifiable {
    let id: Int64
    let imageName: String
    let clothName: String
    let brandName: String
    let description: String
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
}

struct TodayDailyCodi {
    let coordinateImageUrl: String
    let payloads: [CodiPayload]
}

struct CodiPayload {
    let clothId: Int64
    let locationX: Double
    let locationY: Double
    let ratio: Double
    let degree: Double
    let order: Int
}

// MARK: - Codi Coordinate Request (for server)
struct CodiCoordinateRequestDTO: Codable {
    let coordinateImageUrl: String
    let Payload: [CodiCoordinatePayloadDTO]
}

struct CodiCoordinatePayloadDTO: Codable {
    let clothId: Int64
    let locationX: Double
    let locationY: Double
    let ratio: Double
    let degree: Double
    let order: Int
}

// MARK: - Draggable Image
struct DraggableImageEntity: Identifiable, Hashable {
    let id: Int
    let name: String
    var position: CGPoint
    var scale: CGFloat
    var rotationAngle: Double
    let imageURL: String? = nil
}
