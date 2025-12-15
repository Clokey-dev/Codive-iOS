//
//  ClothTag.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation
import CoreGraphics

// MARK: - ClothTag
struct ClothTag: Identifiable, Equatable, Hashable {
    let id: UUID
    let clothId: Int
    let brand: String
    let name: String
    var locationX: CGFloat
    var locationY: CGFloat

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ClothTag, rhs: ClothTag) -> Bool {
        lhs.id == rhs.id
    }
}
