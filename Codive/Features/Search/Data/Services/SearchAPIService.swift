//
//  SearchAPIService.swift
//  Codive
//
//  Created by 한금준 on 1/27/26.
//

import Foundation
import CodiveAPI
import OpenAPIRuntime
import CryptoKit

// MARK: - HomeCategoryAPIService Protocol

protocol SearchAPIServiceProtocol {
    /// 검색 탭 기록 추천
    func fetchSearchRecommendation() async throws -> [SearchRecommendationResponseDTO]
    
    /// 유저 검색
    func fetchSearchMembers(keyword: String, page: Int64, size: Int32) async throws -> SearchUserResponseDTO
    
    /// 전체 유저 검색 엔진 삭제(개발용)
    func fetchSearchMembersUnsyncAll() async throws
    
    /// 전체 유저 검색 엔진 동기화(개발용)
    func fetchSearchMembersSyncAll() async throws
    
    /// 기록 검색
    func fetchSearchHistories(
        keyword: String,
        page: Int64,
        size: Int32,
        sort: Operations.Search_searchHistoryByHashtagsAndCategories.Input.Query.sortPayload?
    ) async throws -> SearchHistoryResponseDTO
    
    /// 전체 기록 검색 엔진 삭제(개발용)
    func fetchSearchHistoryUnsyncAll() async throws
    
    /// 전체 기록 검색 엔진 동기화(개발용)
    func fetchSearchHistorySyncAll() async throws
}

final class SearchAPIService: SearchAPIServiceProtocol {

    private let client: Client
    private let jsonDecoder: JSONDecoder

    init(tokenProvider: TokenProvider = KeychainTokenProvider()) {
        self.client = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: tokenProvider)]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }
}

extension SearchAPIService {
    func fetchSearchRecommendation() async throws -> [SearchRecommendationResponseDTO] {
        let input = Operations.Search_recommendInSearching.Input()
        
        let response = try await client.Search_recommendInSearching(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)
            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseListSearchingRecommendResponse.self, from: data)
            
            let items = decoded.result ?? []

            return items.map { item in
                SearchRecommendationResponseDTO(
                    historyId: item.historyId ?? 0,
                    memberId: item.memberId ?? 0,
                    recommendType: item.recommendType ?? "",
                    title: item.title ?? "",
                    subTitle: item.subTitle ?? "",
                    imageUrl: item.imageUrl ?? ""
                )
            }
            
        case .undocumented(statusCode: let code, _):
            throw SearchAPIError.serverError(statusCode: code, message: "검색 탭 기록 추천 조회 실패")
        }
    }
}

extension SearchAPIService {
    /// 유저 검색
    func fetchSearchMembers(keyword: String, page: Int64, size: Int32) async throws -> SearchUserResponseDTO {
        let input = Operations.Search_searchUserByNickname.Input(
            query: .init(
                keyword: keyword,
                page: page,
                size: size
            )
        )
        
        let response = try await client.Search_searchUserByNickname(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseSliceResponseSearchedMemberResponse.self, from: data)
            
            let content: [SearchUserResponseItem] =
                decoded.result?.content?.map { item -> SearchUserResponseItem in
                    return SearchUserResponseItem(
                        memberId: item.memberId ?? 0,
                        profileImageUrl: item.profileImageUrl ?? "",
                        nickname: item.nickname ?? ""
                    )
                } ?? []
            
            return SearchUserResponseDTO(content: content, isLast: decoded.result?.isLast ?? true)
            
        case .undocumented(statusCode: let code, _):
            throw SearchAPIError.serverError(statusCode: code, message: "유저 검색 실패")
        }
    }
    
    /// 기록 검색
    func fetchSearchHistories(
        keyword: String,
        page: Int64,
        size: Int32,
        sort: Operations.Search_searchHistoryByHashtagsAndCategories.Input.Query.sortPayload?
    ) async throws -> SearchHistoryResponseDTO {
        let input = Operations.Search_searchHistoryByHashtagsAndCategories.Input(
            query: .init(
                keyword: keyword,
                page: page,
                size: size,
                sort: sort
            )
        )
        
        let response = try await client.Search_searchHistoryByHashtagsAndCategories(input)
        
        switch response {
        case .ok(let okResponse):
            let data = try await Data(collecting: okResponse.body.any, upTo: .max)

            let decoded = try jsonDecoder.decode(Components.Schemas.BaseResponseSliceResponseSearchedHistoryResponse.self, from: data)
            
            let content: [SearchHistoryResponseItem] =
                decoded.result?.content?.map { item -> SearchHistoryResponseItem in
                    return SearchHistoryResponseItem(
                        historyId: item.historyId ?? 0,
                        historyImageUrl: item.historyImageUrl ?? "",
                        profileImageUrl: item.profileImageUrl ?? "",
                        nickname: item.nickname ?? ""
                    )
                } ?? []
            
            return SearchHistoryResponseDTO(content: content, isLast: decoded.result?.isLast ?? true)
            
        case .undocumented(statusCode: let code, _):
            throw SearchAPIError.serverError(statusCode: code, message: "기록 검색 실패")
        }
    }
}

extension SearchAPIService {
    /// 전체 유저 검색 엔진 삭제(개발용)
    func fetchSearchMembersUnsyncAll() async throws {
        let input = Operations.Search_unSyncAllMembers.Input()
        let response = try await client.Search_unSyncAllMembers(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw SearchAPIError.serverError(statusCode: code, message: "전체 유저 검색 엔진 삭제 실패")
        }
    }
    
    /// 전체 유저 검색 엔진 동기화(개발용)
    func fetchSearchMembersSyncAll() async throws {
        let input = Operations.Search_syncAllMembers.Input()
        let response = try await client.Search_syncAllMembers(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw SearchAPIError.serverError(statusCode: code, message: "전체 유저 검색 엔진 동기화 실패")
        }
    }
    
    /// 전체 기록 검색 엔진 삭제(개발용)
    func fetchSearchHistoryUnsyncAll() async throws {
        let input = Operations.Search_unSyncAllHistories.Input()
        let response = try await client.Search_unSyncAllHistories(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw SearchAPIError.serverError(statusCode: code, message: "전체 기록 검색 엔진 삭제 실패")
        }
    }
    
    /// 전체 기록 검색 엔진 동기화(개발용)
    func fetchSearchHistorySyncAll() async throws {
        let input = Operations.Search_syncAllHistories.Input()
        let response = try await client.Search_syncAllHistories(input)

        switch response {
        case .ok:
            return
        case .undocumented(statusCode: let code, _):
            throw SearchAPIError.serverError(statusCode: code, message: "전체 기록 검색 엔진 동기화 실패")
        }
    }
}

// MARK: - ClothAPIError

enum SearchAPIError: LocalizedError {
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
