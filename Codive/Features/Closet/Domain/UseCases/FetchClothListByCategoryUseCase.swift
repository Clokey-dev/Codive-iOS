//
//  FetchClothListByCategoryUseCase.swift
//  Codive
//
//  카테고리 기준 옷 목록 조회 (옷장 리포트의 카테고리별/아이템별 바텀시트용).
//

import Foundation

final class FetchClothListByCategoryUseCase {

    private let repository: ClothRepository

    init(repository: ClothRepository) {
        self.repository = repository
    }

    func execute(
        categoryId: Int,
        size: Int = 50
    ) async throws -> [Cloth] {
        let result = try await repository.fetchClothList(
            lastClothId: nil,
            size: size,
            categoryId: categoryId,
            seasons: []
        )
        return result.clothes
    }
}
