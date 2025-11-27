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

    func saveClothes(_ inputs: [ClothInput], images: [Data]) async throws -> [Cloth] {
        // TODO: 서버 연결 시 아래 로직으로 구현
        // 1. ClothInput + Data → ClothRequestDTO 변환
        // 2. dataSource.uploadClothes(dtos) 호출
        // 3. 서버 응답 ClothResponseDTO → Cloth Entity 변환 후 반환

        // 임시 구현: 더미 데이터 반환
        return inputs.enumerated().map { index, input in
            Cloth(
                id: index,
                imageUrl: "", // 서버 연결 시 Presigned URL로 업로드 후 받은 URL
                name: input.name.isEmpty ? nil : input.name,
                brand: input.brand.isEmpty ? nil : input.brand,
                purchaseUrl: input.purchaseUrl.isEmpty ? nil : input.purchaseUrl,
                categoryId: input.categoryId,
                seasons: input.seasons
            )
        }

        /* 서버 연결 시 실제 구현:
        let dtos = zip(inputs, images).map { input, imageData in
            ClothRequestDTO(
                image: imageData,
                name: input.name.isEmpty ? nil : input.name,
                brand: input.brand.isEmpty ? nil : input.brand,
                purchaseUrl: input.purchaseUrl.isEmpty ? nil : input.purchaseUrl,
                categoryId: input.categoryId,
                seasons: input.seasons.map { $0.rawValue }
            )
        }

        let responseDTOs = try await dataSource.uploadClothes(dtos)
        return responseDTOs.map { $0.toEntity() }
        */
    }
}
