//
//  ProductUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/23/25.
//

final class ProductUseCase {

    // MARK: - Dependency
    private let repository: LookBookRepository

    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }

    // MARK: - Methods
    func execute(category: String? = nil) async throws -> [ProductItem] {
        return try await repository.fetchClothItems(category: category)
    }
}
