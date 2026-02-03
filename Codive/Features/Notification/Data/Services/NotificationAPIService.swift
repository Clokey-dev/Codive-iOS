//
//  NotificationAPIService.swift
//  Codive
//
//  Created by 한금준 on 1/24/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime
import CryptoKit

// MARK: - HomeCategoryAPIService Protocol

protocol NotificationAPIServiceProtocol {
    func patchEachNotification(notificationId: Int64) async throws
    
    func patchAllNotification() async throws
    
    func fetchNotificationList(lastNotificationId: Int64?, size: Int32) async throws -> NotificationListResponseDTO
    
    func fetchNotificationExist() async throws -> NotificationExistAPIResponseDTO
    
    func fetchReportReceived() async throws -> ReportReceivedAPIResponseDTO
}

final class NotificationAPIService: NotificationAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }
}

extension NotificationAPIService {
    func patchEachNotification(notificationId: Int64) async throws {
        let input = Operations.updateReadStatus.Input(path: .init(notificationId: notificationId))
        let response = try await client.updateReadStatus(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw NotificationAPIError.serverError(statusCode: code, message: "알림 읽음 처리 실패")
        }
    }
    
    func patchAllNotification() async throws {
        let input = Operations.updateAllReadStatus.Input()
        let response = try await client.updateAllReadStatus(input)
        
        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw NotificationAPIError.serverError(statusCode: code, message: "알림 전체 읽음 처리 실패")
        }
    }
}

extension NotificationAPIService {
    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "" }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter.string(from: date)
    }
    
    func fetchNotificationList(lastNotificationId: Int64?, size: Int32) async throws -> NotificationListResponseDTO {
        let input = Operations.Notification_getNotificationList.Input(
            query: .init(
                lastNotificationId: lastNotificationId,
                size: size
            )
        )
        
        let response = try await client.Notification_getNotificationList(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseSliceResponseNotificationListResponse.self, from: data)
            
            let content: [NotificationListResponseItem] = decoded.result?.content?.map { item -> NotificationListResponseItem in
                return NotificationListResponseItem(
                    notificationId: item.notificationId ?? 0,
                    notificationImageUrl: item.notificationImageUrl ?? "",
                    notificationContent: item.notificationContent ?? "",
                    redirectInfo: item.redirectInfo ?? "",
                    redirectType: item.redirectType?.rawValue ?? "",
                    readStatus: item.readStatus?.rawValue ?? "",
                    createdAt: formatDate(item.createdAt)
                )
            } ?? []
            
            return NotificationListResponseDTO(content: content, isLast: decoded.result?.isLast ?? true)
            
        case .undocumented(statusCode: let code, _):
            throw NotificationAPIError.serverError(statusCode: code, message: "개별 룩북 코디 목록 조회 실패")
        }
    }
    
    func fetchReportReceived() async throws -> ReportReceivedAPIResponseDTO {
        let input = Operations.Report_checkReportReceived.Input()
        
        let response = try await client.Report_checkReportReceived(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseReportedCheckResponse.self, from: data)
            
            guard let item = decoded.result else {
                throw NotificationAPIError.invalidResponse
            }

            return ReportReceivedAPIResponseDTO(
                isReported: item.isReported ?? false,
                targetType: item.targetType.flatMap { ReportType(rawValue: $0.rawValue) }
            )
            
        case .undocumented(statusCode: let code, _):
            throw NotificationAPIError.serverError(statusCode: code, message: "개별 룩북 코디 목록 조회 실패")
        }
    }
}

extension NotificationAPIService {
    
    func fetchNotificationExist() async throws -> NotificationExistAPIResponseDTO {
        
        let input = Operations.Notification_existsUnreadNotification.Input()
        
        let response = try await client.Notification_existsUnreadNotification(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseUnreadNotificationResponse.self, from: data)
            
            guard let exists = decoded.result?.existsUnreadNotification else {
                throw HomeAPIError.invalidResponse
            }
            
            return NotificationExistAPIResponseDTO(
                existsUnreadNotification: exists
            )
            
        case .undocumented(statusCode: let code, _):
            throw NotificationAPIError.serverError(statusCode: code, message: "안읽은 알림 존재 유무 확인 실패")
        }
    }
}

// MARK: - ClothAPIError

enum NotificationAPIError: LocalizedError {
    case presignedUrlMismatch
    case invalidUrl
    case invalidResponse
    case s3UploadFailed(statusCode: Int)
    case noClothIdsReturned
    case serverError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .presignedUrlMismatch:
            return "Presigned URL 개수가 요청한 이미지 개수와 일치하지 않습니다."
        case .invalidUrl:
            return "유효하지 않은 URL입니다."
        case .invalidResponse:
            return "서버 응답을 처리할 수 없습니다."
        case .s3UploadFailed(let statusCode):
            return "S3 업로드 실패 (상태 코드: \(statusCode))"
        case .noClothIdsReturned:
            return "서버에서 생성된 옷 ID를 반환하지 않았습니다."
        case .serverError(let statusCode, let message):
            return "서버 오류 (\(statusCode)): \(message)"
        }
    }
}
