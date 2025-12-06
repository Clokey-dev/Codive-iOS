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
    @Published var displayableTags: [[ClothTag]] = []
    @Published var formattedDate: String = ""
    @Published var displayableStyles: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var likers: [User] = [] // 좋아요 누른 유저 목록
    @Published var isLikesSheetPresented: Bool = false // 좋아요 목록 시트 표시 여부

    // MARK: - Private Properties

    private let feedId: Int
    private let fetchFeedDetailUseCase: FetchFeedDetailUseCase
    private let fetchLikersUseCase: FetchFeedLikersUseCase // FetchFeedLikersUseCase 추가
    private let feedRepository: FeedRepository
    private let navigationRouter: NavigationRouter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = TextLiteral.Feed.dateFormat
        return formatter
    }()

    // MARK: - Initializer

    init(
        feedId: Int,
        fetchFeedDetailUseCase: FetchFeedDetailUseCase,
        fetchLikersUseCase: FetchFeedLikersUseCase, // FetchLikersUseCase 주입
        feedRepository: FeedRepository,
        navigationRouter: NavigationRouter
    ) {
        self.feedId = feedId
        self.fetchFeedDetailUseCase = fetchFeedDetailUseCase
        self.fetchLikersUseCase = fetchLikersUseCase
        self.feedRepository = feedRepository
        self.navigationRouter = navigationRouter
    }

    // MARK: - Feed 상세 로딩

    func loadFeedDetail() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let fetchedFeed = try await fetchFeedDetailUseCase.execute(feedId: feedId)
            
            // 데이터 가공
            self.feed = fetchedFeed
            self.displayableTags = mapToDisplayableTags(from: fetchedFeed.images)
            self.formattedDate = format(date: fetchedFeed.createdAt)
            
            // TODO: styleIds를 실제 스타일 이름으로 변환하는 로직 구현 필요
            self.displayableStyles = [] // 현재는 임시로 빈 배열 할당

        } catch {
            errorMessage = TextLiteral.Feed.loadDetailFailed
            feed = nil
            displayableTags = []
            formattedDate = ""
            displayableStyles = []
        }

        isLoading = false
    }
    
    // MARK: - Data Transformation
    
    private func mapToDisplayableTags(from images: [FeedImage]) -> [[ClothTag]] {
        images.map { image in
            image.tags.map { tag in
                // TODO: API 연동 시 clothId로 실제 옷 정보(brand, name) 조회하여 사용
                ClothTag(
                    id: tag.id,
                    clothId: tag.clothId,
                    brand: TextLiteral.Feed.defaultBrand,
                    name: TextLiteral.Feed.defaultProductName + " \(tag.clothId)",
                    locationX: CGFloat(tag.locationX),
                    locationY: CGFloat(tag.locationY)
                )
            }
        }
    }
    
    private func format(date: Date?) -> String {
        guard let date = date else { return "" }
        return dateFormatter.string(from: date)
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
            return current + 1
        } else {
            return max(0, current - 1)
        }
    }
    
    // MARK: - 좋아요 목록 화면 이동
    
    /// 좋아요 개수를 탭했을 때 좋아요 목록 시트
    func likesCountTapped() {
        Task {
            do {
                self.likers = try await fetchLikersUseCase.execute(feedId: self.feedId)
                self.isLikesSheetPresented = true
            } catch {
                errorMessage = "좋아요 목록을 불러오는데 실패했습니다."
            }
        }
    }
    
    // MARK: - 댓글 화면 이동
    func commentButtonTapped() {
        navigationRouter.presentSheet(for: .comment(feedId: self.feedId))
    }
}
