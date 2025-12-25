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

    func updateCategories(_ categories: [CategoryEntity]) {
        repository.saveCategories(categories)
    }
}
