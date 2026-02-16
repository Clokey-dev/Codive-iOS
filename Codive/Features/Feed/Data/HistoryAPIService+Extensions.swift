//
//  HistoryAPIService+Extensions.swift
//  Codive
//
//  Created by 황상환 on 1/13/26.
//

import Foundation
import CodiveAPI
import CryptoKit

// MARK: - Presigned URL & S3 Upload

extension HistoryAPIService {

    func getPresignedUrls(for images: [Data]) async throws -> [PresignedUrlInfo] {
        let payloads = images.map { imageData in
            let md5Hash = calculateMD5(from: imageData)
            return (
                payload: Components.Schemas.HistoryImagesUploadRequestPayload(fileExtension: .JPEG, md5Hashes: md5Hash),
                md5Hash: md5Hash
            )
        }

        let requestBody = Components.Schemas.HistoryImagesUploadRequest(payloads: payloads.map { $0.payload })
        let input = Operations.History_getHistoryUploadPresignedUrl.Input(body: .json(requestBody))
        let response = try await client.History_getHistoryUploadPresignedUrl(input)

        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseHistoryImagesPresignedUrlResponse.self, from: data)

            guard let urls = decoded.result?.urls, urls.count == images.count else {
                throw HistoryAPIError.noData
            }

            return zip(urls, payloads).map { url, payloadInfo in
                PresignedUrlInfo(presignedUrl: url, finalUrl: extractFinalUrl(from: url), md5Hash: payloadInfo.md5Hash)
            }

        case .undocumented(statusCode: let code, _):
            throw HistoryAPIError.serverError(statusCode: code, detail: "Presigned URL 발급 실패")
        }
    }

    func uploadImageToS3(presignedUrl: String, imageData: Data, contentMD5: String) async throws {
        guard let url = URL(string: presignedUrl) else {
            throw HistoryAPIError.serverError(statusCode: 0, detail: "잘못된 URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue(contentMD5, forHTTPHeaderField: "Content-MD5")
        request.httpBody = imageData

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw HistoryAPIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0, detail: "S3 업로드 실패")
        }
    }

    func calculateMD5(from data: Data) -> String {
        let digest = Insecure.MD5.hash(data: data)
        return Data(digest).base64EncodedString()
    }

    func extractFinalUrl(from presignedUrl: String) -> String {
        guard let url = URL(string: presignedUrl),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return presignedUrl
        }
        components.query = nil
        return components.string ?? presignedUrl
    }
}

// MARK: - Response Types

private struct HistoryCreateResponse: Decodable {
    let isSuccess: Bool?
    let code: String?
    let message: String?
    let result: HistoryResult?

    struct HistoryResult: Decodable {
        let historyId: Int64?
    }
}

// MARK: - Error

enum HistoryAPIError: LocalizedError {
    case noData
    case serverError(statusCode: Int, detail: String? = nil)

    var errorDescription: String? {
        switch self {
        case .noData:
            return "응답 데이터가 없습니다."
        case .serverError(let code, let detail):
            if let detail = detail, !detail.isEmpty {
                return "서버 오류 (\(code)): \(detail)"
            }
            return "서버 오류 (\(code))"
        }
    }
}
