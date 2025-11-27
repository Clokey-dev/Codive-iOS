//
//  FetchClothItemsUseCase.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation

// MARK: - FetchClothItemsUseCase
final class FetchClothItemsUseCase {
    
    // MARK: - Properties
    private let repository: ClothRepository
    
    // MARK: - Initializer
    init(repository: ClothRepository) {
        self.repository = repository
    }
    
    // MARK: - Methods
    func execute(category: String? = nil) async throws -> [ProductItem] {
        return try await repository.fetchClothItems(category: category)
    }
}
