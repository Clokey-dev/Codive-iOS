//
//  DeleteClothItemsUseCase.swift
//  Codive
//
//  Created by Claude on 12/21/25.
//

import Foundation

// MARK: - DeleteClothItemsUseCase
final class DeleteClothItemsUseCase {

    // MARK: - Properties
    private let repository: ClothRepository

    // MARK: - Initializer
    init(repository: ClothRepository) {
        self.repository = repository
    }

    // MARK: - Methods
    func execute(clothIds: [Int]) async throws {
        try await repository.deleteClothItems(clothIds)
    }
}
