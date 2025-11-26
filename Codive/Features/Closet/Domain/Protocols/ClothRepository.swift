//
//  ClothRepository.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation
import UIKit

// MARK: - ClothRepository
protocol ClothRepository {
    func fetchClothItems(category: String?) async throws -> [ProductItem]
    func saveClothes(_ clothForms: [ClothFormData], images: [UIImage]) async throws -> [Cloth]
}
