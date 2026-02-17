//
//  ClothAIUseCase.swift
//  Codive
//
//  Created by Claude on 2/17/26.
//

import Foundation

// MARK: - ClothAIUseCase Protocol

protocol ClothAIUseCase {
    /// 이미지를 S3에 업로드합니다.
    func uploadImages(images: [Data]) async throws -> [String]

    /// 이미지에서 옷 정보(누끼/카테고리/계절)를 추출합니다.
    func extractClothInfo(clothImageUrls: [String]) async throws -> [ClothAIInfo]

    /// 이미 업로드된 이미지 URL로 옷을 생성합니다.
    func createClothesWithUrls(inputs: [ClothInput], imageUrls: [String]) async throws -> [Int64]
}

// MARK: - DefaultClothAIUseCase

final class DefaultClothAIUseCase: ClothAIUseCase {

    // MARK: - Properties
    private let apiService: ClothAPIServiceProtocol

    // MARK: - Initializer
    init(apiService: ClothAPIServiceProtocol) {
        self.apiService = apiService
    }

    // MARK: - Methods

    func uploadImages(images: [Data]) async throws -> [String] {
        let presignedInfos = try await apiService.getPresignedUrls(for: images)

        for (imageData, presignedInfo) in zip(images, presignedInfos) {
            try await apiService.uploadImageToS3(
                presignedUrl: presignedInfo.presignedUrl,
                imageData: imageData,
                contentMD5: presignedInfo.md5Hash
            )
        }

        return presignedInfos.map { $0.finalUrl }
    }

    func extractClothInfo(clothImageUrls: [String]) async throws -> [ClothAIInfo] {
        return try await apiService.extractClothInfo(clothImageUrls: clothImageUrls)
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
        return try await apiService.createClothes(requests: requests)
    }
}
