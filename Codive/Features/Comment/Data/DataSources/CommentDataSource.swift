//
//  CommentDataSource.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation
import CodiveAPI

// MARK: - Protocol
protocol CommentDataSource {
    func fetchComments(feedId: Int, page: Int) async throws -> (comments: [Comment], hasNext: Bool)
    func postComment(feedId: Int, content: String) async throws -> Comment
    func fetchReplies(commentId: Int, page: Int) async throws -> (replies: [Comment], hasNext: Bool)
    func postReply(feedId: Int, commentId: Int, content: String) async throws -> Comment
}

// MARK: - Default Implementation (CodiveAPI)
final class DefaultCommentDataSource: CommentDataSource {
    private let apiClient: Client
    private let jsonDecoder: JSONDecoder

    init() {
        self.apiClient = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: KeychainTokenProvider())]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }

    init(apiClient: Client) {
        self.apiClient = apiClient
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
    }

    func fetchComments(feedId: Int, page: Int) async throws -> (comments: [Comment], hasNext: Bool) {
        let response = try await apiClient.Comment_getComments(
            query: Operations.Comment_getComments.Input.Query(
                historyId: Int64(feedId),
                lastCommentId: nil,
                size: 10,
                direction: .DESC
            )
        )

        switch response {
        case .ok(let okResponse):
            let httpBody = try okResponse.body.any
            let data = try await Data(collecting: httpBody, upTo: .max)

            let apiResponse = try jsonDecoder.decode(
                Components.Schemas.BaseResponseSliceResponseCommentListResponse.self,
                from: data
            )

            let comments = (apiResponse.result?.content ?? []).map { Comment.from(apiResponse: $0) }
            let hasNext = !(apiResponse.result?.isLast ?? true)

            return (comments: comments, hasNext: hasNext)
        default:
            if case .undocumented(let statusCode, let payload) = response {
                if let body = payload.body {
                    let data = try await Data(collecting: body, upTo: .max)
                    if let responseBody = String(data: data, encoding: .utf8) {
                        print("fetchComments error response [\(statusCode)]: \(responseBody)")
                    }
                }
            }
            print("fetchComments response: \(response)")
            throw NSError(domain: "CommentDataSource", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch comments"])
        }
    }

    func postComment(feedId: Int, content: String) async throws -> Comment {
        let body = Components.Schemas.CommentCreateRequest(
            historyId: Int64(feedId),
            content: content
        )

        let response = try await apiClient.Comment_createComment(
            body: .json(body)
        )

        switch response {
        case .ok(let okResponse):
            let httpBody = try okResponse.body.any
            let data = try await Data(collecting: httpBody, upTo: .max)

            let apiResponse = try jsonDecoder.decode(
                Components.Schemas.BaseResponseCommentCreateResponse.self,
                from: data
            )

            guard let commentId = apiResponse.result?.commentId else {
                throw NSError(domain: "CommentDataSource", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
            }

            // 새로운 댓글 객체 생성 (추가 정보는 필요하면 별도로 조회)
            let currentUser = User(id: "", nickname: "현재 사용자", profileImageUrl: nil)
            let newComment = Comment(
                id: Int(commentId),
                content: content,
                author: currentUser,
                isMine: true,
                hasReplies: false,
                replies: []
            )

            return newComment
        default:
            throw NSError(domain: "CommentDataSource", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to post comment"])
        }
    }

    func fetchReplies(commentId: Int, page: Int) async throws -> (replies: [Comment], hasNext: Bool) {
        let response = try await apiClient.Comment_getReplies(
            path: Operations.Comment_getReplies.Input.Path(commentId: Int64(commentId)),
            query: Operations.Comment_getReplies.Input.Query(
                lastReplyId: nil,
                size: 10,
                direction: .DESC
            )
        )

        switch response {
        case .ok(let okResponse):
            let httpBody = try okResponse.body.any
            let data = try await Data(collecting: httpBody, upTo: .max)

            let apiResponse = try jsonDecoder.decode(
                Components.Schemas.BaseResponseSliceResponseReplyListResponse.self,
                from: data
            )

            let replies = (apiResponse.result?.content ?? []).map { Comment.from(apiResponse: $0) }
            let hasNext = !(apiResponse.result?.isLast ?? true)

            return (replies: replies, hasNext: hasNext)
        default:
            throw NSError(domain: "CommentDataSource", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch replies"])
        }
    }

    func postReply(feedId: Int, commentId: Int, content: String) async throws -> Comment {
        // 대댓글 작성용 요청
        let body = Components.Schemas.CommentCreateRequest(
            historyId: Int64(feedId),
            content: content
        )

        let response = try await apiClient.Comment_createReply(
            path: Operations.Comment_createReply.Input.Path(commentId: Int64(commentId)),
            body: .json(body)
        )

        switch response {
        case .ok(let okResponse):
            let httpBody = try okResponse.body.any
            let data = try await Data(collecting: httpBody, upTo: .max)

            let apiResponse = try jsonDecoder.decode(
                Components.Schemas.BaseResponseCommentCreateResponse.self,
                from: data
            )

            guard let replyId = apiResponse.result?.commentId else {
                throw NSError(domain: "CommentDataSource", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
            }

            // 새로운 대댓글 객체 생성
            let currentUser = User(id: "", nickname: "현재 사용자", profileImageUrl: nil)
            let newReply = Comment(
                id: Int(replyId),
                content: content,
                author: currentUser,
                isMine: true,
                hasReplies: false,
                replies: []
            )

            return newReply
        default:
            print("postReply response: \(response)")
            throw NSError(domain: "CommentDataSource", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to post reply"])
        }
    }
}

// MARK: - Mock Implementation
final class MockCommentDataSource: CommentDataSource {
    func fetchComments(feedId: Int, page: Int) async throws -> (comments: [Comment], hasNext: Bool) {
        try await Task.sleep(nanoseconds: 500_000_000)

        if page == 0 {
            return (comments: CommentMockData.comments, hasNext: true)
        } else {
            return (comments: [], hasNext: false)
        }
    }

    func postComment(feedId: Int, content: String) async throws -> Comment {
        try await Task.sleep(nanoseconds: 300_000_000)

        let newComment = Comment(
            id: Int.random(in: 100...999),
            content: content,
            author: CommentMockData.users[2], // "CurrentUser"
            isMine: true
        )
        return newComment
    }

    func fetchReplies(commentId: Int, page: Int) async throws -> (replies: [Comment], hasNext: Bool) {
        try await Task.sleep(nanoseconds: 500_000_000)
        return (replies: [], hasNext: false)
    }

    func postReply(feedId: Int, commentId: Int, content: String) async throws -> Comment {
        try await Task.sleep(nanoseconds: 300_000_000)

        let newReply = Comment(
            id: Int.random(in: 100...999),
            content: content,
            author: CommentMockData.users[2],
            isMine: true
        )
        return newReply
    }
}
