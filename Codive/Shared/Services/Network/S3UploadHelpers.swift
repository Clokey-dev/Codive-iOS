//
//  S3UploadHelpers.swift
//  Codive
//
//  Created by 황상환 on 2/17/26.
//

import Foundation
import CryptoKit

enum S3UploadHelpers {

    static func calculateMD5(from data: Data) -> String {
        let digest = Insecure.MD5.hash(data: data)
        return Data(digest).base64EncodedString()
    }

    static func extractFinalUrl(from presignedUrl: String) -> String {
        guard let url = URL(string: presignedUrl),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return presignedUrl
        }
        components.query = nil
        return components.string ?? presignedUrl
    }

    static func uploadToS3(presignedUrl: String, imageData: Data, contentMD5: String) async throws {
        guard let url = URL(string: presignedUrl) else {
            throw S3UploadError.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue(contentMD5, forHTTPHeaderField: "Content-MD5")
        request.httpBody = imageData

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw S3UploadError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw S3UploadError.uploadFailed(statusCode: httpResponse.statusCode)
        }
    }
}

enum S3UploadError: LocalizedError {
    case invalidUrl
    case invalidResponse
    case uploadFailed(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "유효하지 않은 URL입니다."
        case .invalidResponse:
            return "서버 응답을 처리할 수 없습니다."
        case .uploadFailed(let statusCode):
            return "S3 업로드 실패 (상태 코드: \(statusCode))"
        }
    }
}
