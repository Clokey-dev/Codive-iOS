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
    func deleteComment(commentId: Int) async throws
}

// MARK: - Default Implementation (CodiveAPI)
final class DefaultCommentDataSource: CommentDataSource {
    private let apiClient: Client
    private let jsonDecoder: JSONDecoder
    private var currentUser: User

    init() {
        self.apiClient = CodiveAPIProvider.createClient(
            middlewares: [CodiveAuthMiddleware(provider: KeychainTokenProvider())]
        )
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
        if let profile = UserProfileStorage.load() {
            self.currentUser = User(
                id: String(profile.userId),
                nickname: profile.nickname,
                profileImageUrl: profile.profileImageUrl
            )
        } else {
            self.currentUser = User(id: "", nickname: "", profileImageUrl: nil)
        }
    }

    init(apiClient: Client) {
        self.apiClient = apiClient
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
        if let profile = UserProfileStorage.load() {
            self.currentUser = User(
                id: String(profile.userId),
                nickname: profile.nickname,
                profileImageUrl: profile.profileImageUrl
            )
        } else {
            self.currentUser = User(id: "", nickname: "", profileImageUrl: nil)
        }
    }

    init(apiClient: Client, currentUser: User) {
        self.apiClient = apiClient
        self.jsonDecoder = JSONDecoderFactory.makeAPIDecoder()
        self.currentUser = currentUser
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
            #if DEBUG
            if case .undocumented(let statusCode, let payload) = response {
                if let body = payload.body {
                    let data = try await Data(collecting: body, upTo: .max)
                    if let responseBody = String(data: data, encoding: .utf8) {
                        print("[Comment] fetchComments error [\(statusCode)]: \(responseBody)")
                    }
                }
            }
            #endif
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

            let newComment = Comment(
                id: Int(commentId),
                content: content,
                author: currentUser,
                isMine: true,
                hasReplies: false,
                replies: nil
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

            let newReply = Comment(
                id: Int(replyId),
                content: content,
                author: currentUser,
                isMine: true,
                hasReplies: false,
                replies: nil
            )

            return newReply
        default:
            throw NSError(domain: "CommentDataSource", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to post reply"])
        }
    }

    func deleteComment(commentId: Int) async throws {
        let response = try await apiClient.Comment_deleteComment(
            path: Operations.Comment_deleteComment.Input.Path(commentId: Int64(commentId))
        )

        switch response {
        case .ok:
            return
        default:
            throw NSError(domain: "CommentDataSource", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to delete comment"])
        }
    }
}

// MARK: - Mock Implementation
final class MockCommentDataSource: CommentDataSource {
    private var commentIdCounter = 1000
    private var replyIdCounter = 10000

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

        commentIdCounter += 1
        let newComment = Comment(
            id: commentIdCounter,
            content: content,
            author: CommentMockData.users[2],
            isMine: true,
            hasReplies: false,
            replyCount: 0
        )
        return newComment
    }

    func fetchReplies(commentId: Int, page: Int) async throws -> (replies: [Comment], hasNext: Bool) {
        try await Task.sleep(nanoseconds: 500_000_000)
        return (replies: [], hasNext: false)
    }

    func postReply(feedId: Int, commentId: Int, content: String) async throws -> Comment {
        try await Task.sleep(nanoseconds: 300_000_000)

        replyIdCounter += 1
        let newReply = Comment(
            id: replyIdCounter,
            content: content,
            author: CommentMockData.users[2],
            isMine: true,
            hasReplies: false,
            replyCount: 0
        )
        return newReply
    }

    func deleteComment(commentId: Int) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
}
