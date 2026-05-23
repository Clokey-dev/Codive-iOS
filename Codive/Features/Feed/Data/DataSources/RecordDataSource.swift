//
//  RecordDataSource.swift
//  Codive
//
//  Created by 황상환 on 2025/11/22.
//

import Foundation
import UIKit

// MARK: - Record Create Request

struct RecordCreateRequest {
    let content: String?
    let historyDate: String
    let situationId: Int64
    let styleIds: [Int64]
    let hashtags: [String]
    let photos: [RecordPhoto]
}

struct RecordPhoto {
    let image: UIImage
    let clothTags: [RecordClothTag]
    var imageUrl: String? // 수정 모드에서 기존 이미지 URL 저장
}

struct RecordClothTag {
    let clothId: Int64
    let locationX: Double
    let locationY: Double
}

// MARK: - Protocol

protocol RecordDataSource {
    func createRecord(request: RecordCreateRequest) async throws -> Int64
    func updateRecord(historyId: Int64, request: RecordCreateRequest) async throws
}

// MARK: - Implementation

final class DefaultRecordDataSource: RecordDataSource {

    private let historyAPIService: HistoryAPIServiceProtocol

    init(
        historyAPIService: HistoryAPIServiceProtocol = HistoryAPIService()
    ) {
        self.historyAPIService = historyAPIService
    }

    func createRecord(request: RecordCreateRequest) async throws -> Int64 {
        // Step 1: 이미지 업로드 (Presigned URL → S3)
        let imageUrls = try await uploadImages(photos: request.photos)

        // Step 2: API 요청 생성
        let payloads = zip(imageUrls, request.photos).map { url, photo in
            HistoryImagePayload(
                imageUrl: url,
                clothTags: photo.clothTags
            )
        }

        let apiRequest = HistoryCreateAPIRequest(
            content: request.content,
            historyDate: request.historyDate,
            situationId: request.situationId,
            styleIds: request.styleIds,
            hashtags: request.hashtags,
            payloads: payloads
        )

        // Step 3: 기록 생성 API 호출
        return try await historyAPIService.createHistory(request: apiRequest)
    }

    func updateRecord(historyId: Int64, request: RecordCreateRequest) async throws {
        // 수정 시에는 이미지 URL이 이미 설정되어 있음
        let payloads = request.photos.map { photo in
            HistoryImagePayload(
                imageUrl: photo.imageUrl ?? "", // 기존 이미지 URL 사용
                clothTags: photo.clothTags
            )
        }

        let apiRequest = HistoryCreateAPIRequest(
            content: request.content,
            historyDate: request.historyDate,
            situationId: request.situationId,
            styleIds: request.styleIds,
            hashtags: request.hashtags,
            payloads: payloads
        )

        // 기록 수정 API 호출
        try await historyAPIService.updateHistory(historyId: historyId, request: apiRequest)
    }

    // MARK: - Private Methods

    private func uploadImages(photos: [RecordPhoto]) async throws -> [String] {
        // 이미지 데이터 변환
        let imageDatas = photos.compactMap { photo -> Data? in
            photo.image.jpegData(compressionQuality: 0.8)
        }

        guard imageDatas.count == photos.count else {
            throw RecordDataSourceError.imageConversionFailed
        }

        // Presigned URL 발급 (기록 전용 API)
        let presignedInfos = try await historyAPIService.getPresignedUrls(for: imageDatas)

        // S3 업로드
        for (imageData, presignedInfo) in zip(imageDatas, presignedInfos) {
            let contentType = S3UploadHelpers.detectFormat(from: imageData).contentType
            try await historyAPIService.uploadImageToS3(
                presignedUrl: presignedInfo.presignedUrl,
                imageData: imageData,
                contentMD5: presignedInfo.md5Hash,
                contentType: contentType
            )
        }

        // 최종 URL 반환
        return presignedInfos.map { $0.finalUrl }
    }
}

// MARK: - Error

enum RecordDataSourceError: LocalizedError {
    case imageConversionFailed

    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "이미지 변환에 실패했습니다."
        }
    }
}
