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
    
    func loadClothItems(
        lastClothId: Int64?,
        size: Int = 10,
        categoryId: Int64,
        season: Set<Season>
    ) async throws -> (content: [HomeClothEntity], isLast: Bool) {
        return try await repository.fetchRecommendCategoryClothList(
            lastClothId: lastClothId,
            size: size,
            categoryId: categoryId,
            season: season
        )
    }

    func updateCategories(_ categories: [CategoryEntity]) {
        repository.saveCategories(categories)
    }
}
