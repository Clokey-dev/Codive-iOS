//
//  ClothRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation
import UIKit

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

    func saveClothes(_ clothForms: [ClothFormData], images: [UIImage]) async throws -> [Cloth] {
        // TODO: 서버 연결 시 아래 로직으로 구현
        // 1. ClothFormData + UIImage → ClothRequestDTO 변환
        // 2. dataSource.uploadClothes(dtos) 호출
        // 3. 서버 응답 ClothResponseDTO → Cloth Entity 변환 후 반환

        // 임시 구현: 더미 데이터 반환
        return clothForms.enumerated().map { index, form in
            Cloth(
                id: index,
                imageUrl: "", // 서버 연결 시 업로드된 이미지 URL
                name: form.name.isEmpty ? nil : form.name,
                brand: form.brand.isEmpty ? nil : form.brand,
                purchaseUrl: form.purchaseUrl.isEmpty ? nil : form.purchaseUrl,
                categoryId: nil, // TODO: 서버 연결 시 카테고리 이름 → 서버 ID 매핑 필요
                season: form.selectedSeasons.first // 첫 번째 계절만 사용
            )
        }
    }
}
