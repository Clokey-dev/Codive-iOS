//
//  CategoryUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/25/25.
//

final class CategoryUseCase {

    private let repository: HomeRepository

    init(repository: HomeRepository) {
        self.repository = repository
    }

    func loadCategories() -> [CategoryEntity] {
        return repository.fetchCategories()
    }

    func loadClothItems() -> [HomeClothEntity] {
        return repository.fetchClothItems()
    }
    
    // 새로운 API 기반 메서드
    func loadClothItems(
        lastClothId: Int64? = nil,
        size: Int = 20,
        categoryId: Int64? = nil,
        season: String? = nil
    ) async throws -> [HomeClothEntity] {
        let request = ClothListRequestDTO(
            lastClothId: lastClothId,
            size: size,
            categoryId: categoryId,
            season: season
        )
        
        return try await repository.fetchClothItems(request: request)
    }

    func updateCategories(_ categories: [CategoryEntity]) {
        repository.saveCategories(categories)
    }
}
