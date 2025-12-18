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
    let codiId: Int
    let name: String
    let memo: String
    let imageURL: String
}
