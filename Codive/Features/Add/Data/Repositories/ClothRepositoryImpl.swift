//
//  ClothRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation

// MARK: - ClothRepositoryImpl
final class ClothRepositoryImpl: ClothRepository {
    
    // MARK: - Properties
    private let dataSource: ClothDataSource
    
    // MARK: - Initializer
    init(dataSource: ClothDataSource) {
        self.dataSource = dataSource
    }
    
    // MARK: - Methods
    func fetchClothItems(category: String?) async throws -> [ProductItem] {
        return try await dataSource.fetchClothItems(category: category)
    }
}
