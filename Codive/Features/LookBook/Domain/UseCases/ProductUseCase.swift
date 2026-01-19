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

    // MARK: - Product

    /// 코디 구성에 사용되는 상품 목록 조회
    func fetchProductList() async throws -> [ProductItem] {
        try await repository.fetchProductList()
    }
}
