//
//  LookBookEntity.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import Foundation

struct LookBookEntity: Identifiable {
    let id: Int
    let imageURL: String
    let cardTitle: String
}

struct CodiDetailEntity: Identifiable {
    let id: Int
    let imageURL: String
    let topImageURL: String
    let bottomImageURL: String
    let shoeImageURL: String
    let name: String
    let memo: String
    let date: String
}

// MARK: - Supporting Types
struct SelectedCodiData: Hashable {
    let imageURL: String
    let name: String
    let memo: String
}

struct BeforeCodiEntity: Identifiable {
    let id: Int
    let imageURL: String
    let date: String
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
    let imageURL: String?               // 기존 사용처를 위해 유지 (옵셔널로 변경)
    let name: String
    let memo: String
    var combinedItems: [DraggableImageEntity]? // 새롭게 추가된 필드 (선택적)

    // 기존 사용처(CodiDetail 등)를 위한 기본 생성자 유지
    init(codiId: Int, imageURL: String, name: String, memo: String, combinedItems: [DraggableImageEntity]? = nil) {
        self.codiId = codiId
        self.imageURL = imageURL
        self.name = name
        self.memo = memo
        self.combinedItems = combinedItems
    }
}
