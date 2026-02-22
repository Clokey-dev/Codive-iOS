//
//  ClothAIUseCase.swift
//  Codive
//
//  Created by 황상환 on 2/17/26.
//

import Foundation

// MARK: - ClothAIUseCase Protocol

protocol ClothAIUseCase {
    /// 이미지를 S3에 병렬 업로드합니다. 실패한 이미지는 nil로 반환합니다.
    func uploadImages(images: [Data]) async -> [String?]

    /// 이미지에서 옷 정보(누끼/카테고리/계절)를 추출합니다.
    func extractClothInfo(clothImageUrls: [String]) async throws -> [ClothAIInfo]

    /// 이미 업로드된 이미지 URL로 옷을 생성합니다.
    func createClothesWithUrls(inputs: [ClothInput], imageUrls: [String]) async throws -> [Int64]
}

// MARK: - DefaultClothAIUseCase

final class DefaultClothAIUseCase: ClothAIUseCase {

    // MARK: - Properties
    private let repository: ClothAIRepository

    // MARK: - Initializer
    init(repository: ClothAIRepository) {
        self.repository = repository
    }

    // MARK: - Methods

    func uploadImages(images: [Data]) async -> [String?] {
        return await repository.uploadImages(images: images)
    }

    func extractClothInfo(clothImageUrls: [String]) async throws -> [ClothAIInfo] {
        return try await repository.extractClothInfo(clothImageUrls: clothImageUrls)
    }

    func createClothesWithUrls(inputs: [ClothInput], imageUrls: [String]) async throws -> [Int64] {
        let requests = zip(inputs, imageUrls).map { input, url -> ClothCreateAPIRequest in
            ClothCreateAPIRequest(
                clothImageUrl: url,
                clothUrl: input.purchaseUrl.isEmpty ? nil : input.purchaseUrl,
                name: input.name.isEmpty ? nil : input.name,
                brand: input.brand.isEmpty ? nil : input.brand,
                seasons: Array(input.seasons),
                categoryId: Int64(input.categoryId ?? 0)
            )
        }
        return try await repository.createClothesWithUrls(requests: requests)
    }
}
