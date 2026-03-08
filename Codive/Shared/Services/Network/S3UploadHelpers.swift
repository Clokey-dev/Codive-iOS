//
//  S3UploadHelpers.swift
//  Codive
//
//  Created by 황상환 on 2/17/26.
//

import Foundation
import CryptoKit
import CodiveAPI

// MARK: - ImageFormat

enum ImageFormat {
    case png
    case jpeg
    case webp
    case heic

    var contentType: String {
        switch self {
        case .png: return "image/png"
        case .jpeg: return "image/jpeg"
        case .webp: return "image/webp"
        case .heic: return "image/heic"
        }
    }

    var clothFileExtension: Components.Schemas.ClothImagesUploadRequestPayload.fileExtensionPayload {
        switch self {
        case .png: return .PNG
        case .jpeg: return .JPEG
        case .webp: return .WEBP
        case .heic: return .HEIC
        }
    }

    var historyFileExtension: Components.Schemas.HistoryImagesUploadRequestPayload.fileExtensionPayload {
        switch self {
        case .png: return .PNG
        case .jpeg: return .JPEG
        case .webp: return .WEBP
        case .heic: return .HEIC
        }
    }

    static func detect(from data: Data) -> ImageFormat {
        guard data.count >= 12 else { return .jpeg }

        let bytes = [UInt8](data.prefix(12))

        // PNG: 89 50 4E 47
        if bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 {
            return .png
        }

        // JPEG: FF D8 FF
        if bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF {
            return .jpeg
        }

        // WEBP: RIFF....WEBP
        if bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46
            && bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50 {
            return .webp
        }

        // HEIC/HEIF: ftyp at bytes 4-7
        if bytes[4] == 0x66 && bytes[5] == 0x74 && bytes[6] == 0x79 && bytes[7] == 0x70 {
            return .heic
        }

        return .jpeg
    }
}

// MARK: - S3UploadHelpers

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

    static func detectFormat(from data: Data) -> ImageFormat {
        ImageFormat.detect(from: data)
    }

    static func uploadToS3(presignedUrl: String, imageData: Data, contentMD5: String, contentType: String) async throws {
        guard let url = URL(string: presignedUrl) else {
            throw S3UploadError.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(contentMD5, forHTTPHeaderField: "Content-MD5")

        let (_, response) = try await URLSession.shared.upload(for: request, from: imageData)

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
