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

    // 더보기 메뉴 관련 상태
    @Published var expandedMenuCommentId: Int?
    @Published var menuButtonFrame: CGRect = .zero
    @Published var showDeleteAlert: Bool = false
    @Published var pendingDeleteCommentId: Int?
    @Published var showBlockAlert: Bool = false
    @Published var pendingBlockComment: Comment?

    private var cancellables = Set<AnyCancellable>()

    private let feedId: Int
    private let navigationRouter: NavigationRouter
    private let fetchCommentsUseCase: FetchCommentsUseCase
    private let postCommentUseCase: PostCommentUseCase
    private let fetchRepliesUseCase: FetchRepliesUseCase
    private let postReplyUseCase: PostReplyUseCase
    private let commentRepository: CommentRepository
    private let toggleBlockUseCase: ToggleBlockUseCase
    var dismissAction: () -> Void = {}

    // MARK: - Initializer

    init(
        feedId: Int,
        navigationRouter: NavigationRouter,
        fetchCommentsUseCase: FetchCommentsUseCase,
        postCommentUseCase: PostCommentUseCase,
        fetchRepliesUseCase: FetchRepliesUseCase,
        postReplyUseCase: PostReplyUseCase,
        commentRepository: CommentRepository,
        toggleBlockUseCase: ToggleBlockUseCase
    ) {
        self.feedId = feedId
        self.navigationRouter = navigationRouter
        self.fetchCommentsUseCase = fetchCommentsUseCase
        self.postCommentUseCase = postCommentUseCase
        self.fetchRepliesUseCase = fetchRepliesUseCase
        self.postReplyUseCase = postReplyUseCase
        self.commentRepository = commentRepository
        self.toggleBlockUseCase = toggleBlockUseCase
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
                #if DEBUG
                print("Error fetching comments: \(error)")
                #endif
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
                #if DEBUG
                print("Error reloading comments: \(error)")
                #endif
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
                let newComment = try await postCommentUseCase.execute(feedId: feedId, content: content)
                self.currentCommentText = ""
                // 새 댓글을 맨 위에 추가 (전체 리로드 대신)
                self.comments.insert(newComment, at: 0)
            } catch {
                #if DEBUG
                print("Error posting comment: \(error)")
                #endif
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

    func fetchReplies(for commentId: Int) {
        guard !isReplyLoading else { return }
        isReplyLoading = true

        Task {
            do {
                let result = try await fetchRepliesUseCase.execute(commentId: commentId, page: 0)

                // commentId와 일치하는 댓글을 찾아 대댓글을 업데이트 (최대 10개)
                if let index = self.comments.firstIndex(where: { $0.id == commentId }) {
                    var updatedComments = self.comments
                    let loadedReplies = Array(result.replies.prefix(10))
                    updatedComments[index].replies = loadedReplies
                    updatedComments[index].replyPage = 0
                    updatedComments[index].hasMoreReplies = result.replies.count > 10
                    self.comments = updatedComments
                }
            } catch {
                #if DEBUG
                print("Error fetching replies: \(error)")
                #endif
            }
            self.isReplyLoading = false
        }
    }

    func fetchAllReplies(for commentId: Int) {
        guard !isReplyLoading else { return }
        isReplyLoading = true

        Task {
            do {
                let result = try await fetchRepliesUseCase.execute(commentId: commentId, page: 0)

                // commentId와 일치하는 댓글을 찾아 모든 대댓글을 업데이트
                if let index = self.comments.firstIndex(where: { $0.id == commentId }) {
                    var updatedComments = self.comments
                    updatedComments[index].replies = result.replies
                    updatedComments[index].hasMoreReplies = false
                    self.comments = updatedComments
                }
            } catch {
                #if DEBUG
                print("[Comment] Error fetching all replies: \(error)")
                #endif
            }
            self.isReplyLoading = false
        }
    }

    func postReply() {
        guard !currentReplyText.isEmpty, let commentId = replyingToCommentId else { return }
        let content = currentReplyText

        Task {
            do {
                _ = try await postReplyUseCase.execute(feedId: feedId, commentId: commentId, content: content)

                self.currentReplyText = ""
                self.replyingToCommentId = nil

                // 대댓글 작성 후 최신 대댓글을 다시 조회
                let result = try await fetchRepliesUseCase.execute(commentId: commentId, page: 0)

                if let index = self.comments.firstIndex(where: { $0.id == commentId }) {
                    var updatedComments = self.comments
                    let loadedReplies = Array(result.replies.prefix(10))
                    updatedComments[index].replies = loadedReplies
                    updatedComments[index].replyPage = 0
                    updatedComments[index].hasMoreReplies = result.replies.count > 10
                    updatedComments[index].replyCount = result.replies.count
                    self.comments = updatedComments
                }
            } catch {
                #if DEBUG
                print("Error posting reply: \(error)")
                #endif
            }
        }
    }

    // MARK: - Menu Methods

    func toggleMenu(commentId: Int, buttonFrame: CGRect = .zero) {
        if expandedMenuCommentId == commentId {
            expandedMenuCommentId = nil
        } else {
            menuButtonFrame = buttonFrame
            expandedMenuCommentId = commentId
        }
    }

    func dismissMenu() {
        expandedMenuCommentId = nil
    }

    func onDeleteTapped(commentId: Int) {
        dismissMenu()
        pendingDeleteCommentId = commentId
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.showDeleteAlert = true
        }
    }

    func confirmDelete() {
        guard let commentId = pendingDeleteCommentId else { return }
        pendingDeleteCommentId = nil

        Task {
            do {
                try await commentRepository.deleteComment(commentId: commentId)
                removeComment(id: commentId)
            } catch {
                #if DEBUG
                print("Error deleting comment: \(error)")
                #endif
            }
        }
    }

    func onReportTapped(commentId: Int) {
        dismissMenu()

        // 댓글 정보를 Report 플로우에 라우팅 파라미터로 전달
        var info: CommentReportInfo?
        if let comment = findComment(by: commentId) {
            info = CommentReportInfo(
                feedId: feedId,
                commentId: commentId,
                authorNickname: comment.author.nickname,
                authorProfileImageUrl: comment.author.profileImageUrl,
                content: comment.content,
                authorId: Int(comment.author.id) ?? 0
            )
        }

        dismissAction()
        let capturedInfo = info
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.navigationRouter.navigate(to: .report(target: .comment(id: commentId), commentInfo: capturedInfo))
        }
    }

    func onBlockTapped(comment: Comment) {
        dismissMenu()
        pendingBlockComment = comment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.showBlockAlert = true
        }
    }

    func confirmBlock() {
        guard let comment = pendingBlockComment,
              let memberId = Int(comment.author.id) else { return }
        pendingBlockComment = nil

        Task {
            do {
                try await toggleBlockUseCase.execute(memberId: memberId)
                NotificationCenter.default.post(name: .userDidBlock, object: nil)

                // 차단 후 댓글 시트 닫기 (FeedDetailView가 userDidBlock을 받아 처리)
                dismissAction()
            } catch {
                #if DEBUG
                print("Error blocking user: \(error)")
                #endif
            }
        }
    }

    func findComment(by id: Int) -> Comment? {
        for comment in comments {
            if comment.id == id { return comment }
            if let reply = comment.replies?.first(where: { $0.id == id }) {
                return reply
            }
        }
        return nil
    }

    // MARK: - Navigation

    func navigateToProfile(userId: String, isMine: Bool) {
        guard let memberId = Int(userId) else {
            #if DEBUG
            print("[Comment] Invalid userId: \(userId)")
            #endif
            return
        }

        dismissAction()

        if isMine {
            // 내 댓글이면 내 프로필 뷰로 이동
            navigationRouter.navigate(to: .myProfile)
        } else {
            // 다른 사람 댓글이면 OtherProfileView로 이동
            navigationRouter.navigate(to: .otherProfile(userId: memberId))
        }
    }

    // MARK: - Private Helpers

    private func removeComment(id: Int) {
        // 최상위 댓글에서 찾기
        if let index = comments.firstIndex(where: { $0.id == id }) {
            comments.remove(at: index)
            return
        }
        // 대댓글에서 찾기
        for i in comments.indices {
            if let replyIndex = comments[i].replies?.firstIndex(where: { $0.id == id }) {
                comments[i].replies?.remove(at: replyIndex)
                if let count = comments[i].replyCount, count > 0 {
                    comments[i].replyCount = count - 1
                }
                return
            }
        }
    }
}
