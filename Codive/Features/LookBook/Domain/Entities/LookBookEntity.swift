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
