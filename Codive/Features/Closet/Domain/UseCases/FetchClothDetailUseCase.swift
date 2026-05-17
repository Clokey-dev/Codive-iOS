//
//  FetchClothDetailUseCase.swift
//  Codive
//
//  옷 상세 조회.
//

import Foundation

final class FetchClothDetailUseCase {

    private let repository: ClothRepository

    init(repository: ClothRepository) {
        self.repository = repository
    }

    func execute(clothId: Int) async throws -> ClothDetailResult {
        try await repository.fetchClothDetail(clothId: clothId)
    }
}
