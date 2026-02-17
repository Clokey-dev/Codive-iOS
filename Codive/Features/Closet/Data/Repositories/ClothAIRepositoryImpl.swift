//
//  ClothAIRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 2/17/26.
//

import Foundation

final class ClothAIRepositoryImpl: ClothAIRepository {

    private let apiService: ClothAPIServiceProtocol

    init(apiService: ClothAPIServiceProtocol) {
        self.apiService = apiService
    }

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

    func createClothesWithUrls(requests: [ClothCreateAPIRequest]) async throws -> [Int64] {
        return try await apiService.createClothes(requests: requests)
    }
}
