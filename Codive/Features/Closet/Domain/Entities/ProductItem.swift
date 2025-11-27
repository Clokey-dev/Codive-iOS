//
//  ProductItem.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation

// MARK: - Product Item Model
struct ProductItem: Identifiable {
    let id = UUID()
    let imageName: String
    let isTodayCloth: Bool
    let brand: String?
    let name: String?
}
