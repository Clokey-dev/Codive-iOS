//
//  FeedViewModel.swift
//  Codive
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation

/// Feed 목록 화면의 ViewModel
@MainActor
final class FeedViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Feed 목록
    @Published var feeds: [Feed] = []

    /// 로딩 상태
    @Published var isLoading: Bool = false

    /// 에러 메시지
    @Published var errorMessage: String?

    /// 선택된 스타일 필터
    @Published var selectedStyleIds: [Int]?

    /// 선택된 상황 필터
    @Published var selectedSituationIds: [Int]?

    /// 팔로잉만 보기
    @Published var followingOnly: Bool = false

    // MARK: - Private Properties

    private let navigationRouter: NavigationRouter
    private let fetchFeedsUseCase: FetchFeedsUseCase
    private let feedRepository: FeedRepository
    private var currentPage: Int = 1
    private let pageSize: Int = 20
    private var hasMorePages: Bool = true

    // MARK: - Initialization

    init(
        navigationRouter: NavigationRouter,
        fetchFeedsUseCase: FetchFeedsUseCase,
        feedRepository: FeedRepository
    ) {
        self.navigationRouter = navigationRouter
        self.fetchFeedsUseCase = fetchFeedsUseCase
        self.feedRepository = feedRepository
    }

    // MARK: - Public Methods

    /// Feed 상세보기로 이동
    func navigateToDetail(feedId: Int) {
        navigationRouter.navigate(to: .feedDetail(feedId: feedId))
    }

    /// 첫 페이지 Feed 로드
    func loadFeeds() async {
        // 이미 로딩 중이면 중복 호출 방지
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let newFeeds = try await fetchFeedsUseCase.execute(
                page: 1,
                limit: pageSize,
                styleIds: selectedStyleIds,
                situationIds: selectedSituationIds,
                followingOnly: followingOnly
            )

            feeds = newFeeds
            currentPage = 1
            hasMorePages = newFeeds.count == pageSize
        } catch {
            errorMessage = "Feed를 불러오는데 실패했습니다: \(error.localizedDescription)"
            feeds = []
        }

        isLoading = false
    }

    /// 다음 페이지 Feed 로드 (페이지네이션)
    func loadMoreFeeds() async {
        // 로딩 중이거나 더 이상 페이지가 없으면 리턴
        guard !isLoading, hasMorePages else { return }

        isLoading = true

        do {
            let nextPage = currentPage + 1
            let newFeeds = try await fetchFeedsUseCase.execute(
                page: nextPage,
                limit: pageSize,
                styleIds: selectedStyleIds,
                situationIds: selectedSituationIds,
                followingOnly: followingOnly
            )

            // 기존 Feed에 추가
            feeds.append(contentsOf: newFeeds)
            currentPage = nextPage
            hasMorePages = newFeeds.count == pageSize
        } catch {
            errorMessage = "더 많은 Feed를 불러오는데 실패했습니다: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// 필터 적용 (필터 변경 시 첫 페이지부터 다시 로드)
    func applyFilters() async {
        await loadFeeds()
    }

    /// 새로고침 (첫 페이지부터 다시 로드)
    func refresh() async {
        await loadFeeds()
    }

    /// '팔로잉만 보기' 필터를 끄고 전체 피드를 다시 로드합니다.
    func browseAllFeeds() {
        followingOnly = false
        Task {
            await loadFeeds()
        }
    }

    /// 모든 스타일 및 상황 필터를 초기화하고 피드를 다시 로드합니다.
    func clearFiltersAndReload() {
        selectedStyleIds = nil
        selectedSituationIds = nil
        Task {
            await loadFeeds()
        }
    }

    /// 좋아요 토글
    func toggleLike(feedId: Int) async {
        guard let index = feeds.firstIndex(where: { $0.id == feedId }) else { return }

        let originalFeed = feeds[index]
        let newIsLiked = !(originalFeed.isLiked ?? false)
        let newLikeCount = newIsLiked ? (originalFeed.likeCount ?? 0) + 1 : max(0, (originalFeed.likeCount ?? 0) - 1)

        // 로컬에서 먼저 업데이트
        feeds[index] = Feed(
            id: originalFeed.id,
            content: originalFeed.content,
            author: originalFeed.author,
            images: originalFeed.images,
            situationId: originalFeed.situationId,
            styleIds: originalFeed.styleIds,
            hashtags: originalFeed.hashtags,
            createdAt: originalFeed.createdAt,
            likeCount: newLikeCount,
            isLiked: newIsLiked,
            commentCount: originalFeed.commentCount
        )

        // 서버에 요청
        do {
            try await feedRepository.toggleLike(feedId: feedId)
        } catch {
            // 에러 시 롤백
            feeds[index] = originalFeed
            errorMessage = "좋아요 처리에 실패했습니다"
        }
    }
}
