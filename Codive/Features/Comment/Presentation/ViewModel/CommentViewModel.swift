//
//  CommentViewModel.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation
import Combine

@MainActor
final class CommentViewModel: ObservableObject {

    // MARK: - Properties

    // 댓글 목록
    @Published var comments: [Comment] = []

    // 현재 댓글 입력 텍스트
    @Published var currentCommentText: String = ""

    // 댓글 로딩 상태
    @Published var isLoading: Bool = false

    // 다음 페이지 존재 여부
    @Published var hasNextPage: Bool = true

    // 대댓글 관련 상태
    @Published var replyingToCommentId: Int?
    @Published var currentReplyText: String = ""
    @Published var isReplyLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()

    private let feedId: Int
    private let fetchCommentsUseCase: FetchCommentsUseCase
    private let postCommentUseCase: PostCommentUseCase
    private let fetchRepliesUseCase: FetchRepliesUseCase
    private let postReplyUseCase: PostReplyUseCase
    
    // MARK: - Initializer

    init(
        feedId: Int,
        fetchCommentsUseCase: FetchCommentsUseCase,
        postCommentUseCase: PostCommentUseCase,
        fetchRepliesUseCase: FetchRepliesUseCase,
        postReplyUseCase: PostReplyUseCase
    ) {
        self.feedId = feedId
        self.fetchCommentsUseCase = fetchCommentsUseCase
        self.postCommentUseCase = postCommentUseCase
        self.fetchRepliesUseCase = fetchRepliesUseCase
        self.postReplyUseCase = postReplyUseCase
    }
    
    // MARK: - Public Methods
    
    func fetchFirstPage() {
        guard !isLoading, hasNextPage else { return }
        isLoading = true

        Task {
            do {
                let result = try await fetchCommentsUseCase.execute(feedId: feedId, page: 0)
                self.comments = result.comments
                self.hasNextPage = result.hasNext
            } catch {
                // TODO: 에러 처리
                print("Error fetching comments: \(error)")
            }
            self.isLoading = false
        }
    }

    func reloadComments() {
        isLoading = true

        Task {
            do {
                let result = try await fetchCommentsUseCase.execute(feedId: feedId, page: 0)
                self.comments = result.comments
                self.hasNextPage = result.hasNext
            } catch {
                print("Error reloading comments: \(error)")
            }
            self.isLoading = false
        }
    }

    func fetchNextPage() {
        // TODO: 다음 페이지 로딩 구현 (페이지네이션)
    }
    
    func postComment() {
        guard !currentCommentText.isEmpty else { return }
        let content = currentCommentText

        Task {
            do {
                _ = try await postCommentUseCase.execute(feedId: feedId, content: content)
                self.currentCommentText = ""
                // 댓글 작성 후 목록 다시 로드 (실제 사용자 정보 반영)
                self.reloadComments()
            } catch {
                // TODO: 에러 처리
                print("Error posting comment: \(error)")
            }
        }
    }

    // MARK: - Reply Methods

    func setReplyingTo(commentId: Int) {
        replyingToCommentId = commentId
        currentReplyText = ""
    }

    func cancelReply() {
        replyingToCommentId = nil
        currentReplyText = ""
    }

    func fetchReplies(for commentId: Int, page: Int = 0) {
        guard !isReplyLoading else { return }
        isReplyLoading = true

        Task {
            do {
                let result = try await fetchRepliesUseCase.execute(commentId: commentId, page: page)

                // commentId와 일치하는 댓글을 찾아 대댓글을 업데이트
                if let index = self.comments.firstIndex(where: { $0.id == commentId }) {
                    self.comments[index].replies = result.replies
                }
            } catch {
                print("Error fetching replies: \(error)")
            }
            self.isReplyLoading = false
        }
    }

    func reloadReplies(for commentId: Int) {
        isReplyLoading = true

        Task {
            do {
                let result = try await fetchRepliesUseCase.execute(commentId: commentId, page: 0)

                // commentId와 일치하는 댓글을 찾아 대댓글을 업데이트
                if let index = self.comments.firstIndex(where: { $0.id == commentId }) {
                    self.comments[index].replies = result.replies
                }
            } catch {
                print("Error reloading replies: \(error)")
            }
            self.isReplyLoading = false
        }
    }

    func postReply() {
        guard !currentReplyText.isEmpty, let commentId = replyingToCommentId else { return }
        let content = currentReplyText

        Task {
            do {
                let newReply = try await postReplyUseCase.execute(feedId: feedId, commentId: commentId, content: content)

                self.currentReplyText = ""
                self.replyingToCommentId = nil

                // 대댓글 작성 후 해당 댓글의 replies 배열에 추가
                if let index = self.comments.firstIndex(where: { $0.id == commentId }) {
                    self.comments[index].replies?.append(newReply)
                }
            } catch {
                print("Error posting reply: \(error)")
            }
        }
    }
}
