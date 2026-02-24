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

    func uploadImages(images: [Data]) async -> [String?] {
        // 1. Presigned URL 발급 (한번에 요청)
        let presignedInfos: [PresignedUrlInfo]
        do {
            presignedInfos = try await apiService.getPresignedUrls(for: images)
        } catch {
            #if DEBUG
            print("[ClothAI] Presigned URL 발급 실패: \(error)")
            #endif
            return Array(repeating: nil, count: images.count)
        }

        // 2. S3 병렬 업로드 (개별 실패 허용)
        return await withTaskGroup(of: (Int, String?).self, returning: [String?].self) { group in
            for (index, (imageData, presignedInfo)) in zip(images, presignedInfos).enumerated() {
                group.addTask {
                    do {
                        let contentType = S3UploadHelpers.detectFormat(from: imageData).contentType
                        try await self.apiService.uploadImageToS3(
                            presignedUrl: presignedInfo.presignedUrl,
                            imageData: imageData,
                            contentMD5: presignedInfo.md5Hash,
                            contentType: contentType
                        )
                        return (index, presignedInfo.finalUrl)
                    } catch {
                        #if DEBUG
                        print("[ClothAI] S3 업로드 실패 (index: \(index)): \(error)")
                        #endif
                        return (index, nil)
                    }
                }
            }

            var results = Array<String?>(repeating: nil, count: images.count)
            for await (index, url) in group {
                results[index] = url
            }
            return results
        }
    }

    func extractClothInfo(clothImageUrls: [String]) async throws -> [ClothAIInfo] {
        return try await apiService.extractClothInfo(clothImageUrls: clothImageUrls)
    }

    func createClothesWithUrls(requests: [ClothCreateAPIRequest]) async throws -> [Int64] {
        return try await apiService.createClothes(requests: requests)
    }
}
