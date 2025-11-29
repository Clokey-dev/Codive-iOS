//
//  FeedDetailViewModel.swift
//  Codive
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation

/// Feed 상세 화면의 ViewModel
@MainActor
final class FeedDetailViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var feed: Feed?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let feedId: Int
    private let fetchFeedDetailUseCase: FetchFeedDetailUseCase
    private let feedRepository: FeedRepository

    // MARK: - Initializer

    init(
        feedId: Int,
        fetchFeedDetailUseCase: FetchFeedDetailUseCase,
        feedRepository: FeedRepository
    ) {
        self.feedId = feedId
        self.fetchFeedDetailUseCase = fetchFeedDetailUseCase
        self.feedRepository = feedRepository
    }

    // MARK: - Feed 상세 로딩

    /// Feed 상세 정보를 로드합니다.
    func loadFeedDetail() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            feed = try await fetchFeedDetailUseCase.execute(feedId: feedId)
        } catch {
            errorMessage = "Feed를 불러오는데 실패했습니다."
            feed = nil
        }

        isLoading = false
    }

    // MARK: - 좋아요 토글

    /// 좋아요를 토글합니다 (낙관적 업데이트).
    func toggleLike() async {
        guard let currentFeed = feed else { return }

        // 낙관적 업데이트: UI 먼저 변경
        let originalFeed = currentFeed
        let newIsLiked = !(currentFeed.isLiked ?? false)
        let newLikeCount = calculateNewLikeCount(
            current: currentFeed.likeCount ?? 0,
            isLiked: newIsLiked
        )

        feed = Feed(
            id: currentFeed.id,
            content: currentFeed.content,
            author: currentFeed.author,
            images: currentFeed.images,
            situationId: currentFeed.situationId,
            styleIds: currentFeed.styleIds,
            hashtags: currentFeed.hashtags,
            createdAt: currentFeed.createdAt,
            likeCount: newLikeCount,
            isLiked: newIsLiked,
            commentCount: currentFeed.commentCount
        )

        // 서버 요청
        do {
            try await feedRepository.toggleLike(feedId: currentFeed.id)
        } catch {
            // 실패 시 롤백
            feed = originalFeed
            errorMessage = "좋아요 처리에 실패했습니다."
        }
    }

    private func calculateNewLikeCount(current: Int, isLiked: Bool) -> Int {
        if isLiked {
            return current + 1 // 좋아요 추가
        } else {
            return max(0, current - 1) // 좋아요 취소 (0 이하로 내려가지 않음)
        }
    }
}
