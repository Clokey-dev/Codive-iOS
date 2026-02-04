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

protocol DraggableImageProtocol: Identifiable {
    var id: Int64 { get }
    var imageUrl: String { get }
    var position: CGPoint { get set }
    var scale: CGFloat { get set }
    var rotation: Double { get set }
}

// 실제 프로젝트에서 사용하는 데이터 모델
struct DraggableImageEntity: DraggableImageProtocol, Equatable, Hashable {
    let id: Int64
    let name: String
    var imageUrl: String { name }
    var position: CGPoint
    var scale: CGFloat
    var rotation: Double
}

struct TodayCodiTransferData {
    let images: [DraggableImageEntity]
}

/// 오늘의 코디 옷 정보 조회
struct TodayCoordinateClothEntity {
    let imageUrl: String
    let brand: String
    let name: String
    let category: String
    let parentCategory: String
}
