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

        // 2. S3 업로드 (3장씩 청크 분할하여 동시 메모리 제한)
        let chunkSize = 3
        var results = Array<String?>(repeating: nil, count: images.count)
        let pairs = Array(zip(images, presignedInfos).enumerated())

        for chunkStart in stride(from: 0, to: pairs.count, by: chunkSize) {
            let chunkEnd = min(chunkStart + chunkSize, pairs.count)
            let chunk = pairs[chunkStart..<chunkEnd]

            await withTaskGroup(of: (Int, String?).self) { group in
                for (index, (imageData, presignedInfo)) in chunk {
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
                for await (index, url) in group {
                    results[index] = url
                }
            }
            // 이 청크의 TaskGroup 종료 → 캡처된 Data 해제 가능
        }

        return results
    }

    func extractClothInfo(clothImageUrls: [String]) async throws -> [ClothAIInfo] {
        return try await apiService.extractClothInfo(clothImageUrls: clothImageUrls)
    }

    func createClothesWithUrls(requests: [ClothCreateAPIRequest]) async throws -> [Int64] {
        return try await apiService.createClothes(requests: requests)
    }
}
