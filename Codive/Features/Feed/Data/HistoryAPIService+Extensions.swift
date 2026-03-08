//
//  HistoryAPIService+Extensions.swift
//  Codive
//
//  Created by 황상환 on 1/13/26.
//

import Foundation
import CodiveAPI

// MARK: - Presigned URL & S3 Upload

extension HistoryAPIService {

    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo] {
        let payloads = images.map { imageData in
            let md5Hash = S3UploadHelpers.calculateMD5(from: imageData)
            let format = S3UploadHelpers.detectFormat(from: imageData)
            return (
                payload: Components.Schemas.HistoryImagesUploadRequestPayload(fileExtension: format.historyFileExtension, md5Hashes: md5Hash),
                md5Hash: md5Hash
            )
        }

        let requestBody = Components.Schemas.HistoryImagesUploadRequest(payloads: payloads.map { $0.payload })
        let input = Operations.History_getHistoryUploadPresignedUrl.Input(body: .json(requestBody))
        let response = try await client.History_getHistoryUploadPresignedUrl(input)

        switch response {
        case .ok(let okResponse):
            let decoded = try okResponse.body.json

            guard let urls = decoded.result?.urls, urls.count == images.count else {
                throw HistoryAPIError.noData
            }

            return zip(urls, payloads).map { url, payloadInfo in
                PresignedUrlInfo(presignedUrl: url, finalUrl: S3UploadHelpers.extractFinalUrl(from: url), md5Hash: payloadInfo.md5Hash)
            }

        case .undocumented(statusCode: let code, _):
            throw HistoryAPIError.serverError(statusCode: code, detail: "Presigned URL 발급 실패")
        }
    }

    func uploadImageToS3(presignedUrl: String, imageData: Data, contentMD5: String, contentType: String) async throws {
        try await S3UploadHelpers.uploadToS3(presignedUrl: presignedUrl, imageData: imageData, contentMD5: contentMD5, contentType: contentType)
    }
}
