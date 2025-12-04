//
//  FeedViewModelTests.swift
//  CodiveTests
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation
import Testing
@testable import Codive

/// FeedViewModel의 동작을 검증하는 테스트
@MainActor
struct FeedViewModelTests {

    // MARK: - Test: 초기 로딩

    @Test("ViewModel 생성 시 자동으로 첫 페이지를 로드한다")
    func loadInitialFeeds() async throws {
        // Given
        let mockUseCase = MockFetchFeedsUseCase()
        let mockRepository = MockFeedRepositoryForViewModel()
        let mockRouter = NavigationRouter()
        let viewModel = FeedViewModel(navigationRouter: mockRouter, fetchFeedsUseCase: mockUseCase, feedRepository: mockRepository)

        // When: 초기 로딩
        await viewModel.loadFeeds()

        // Then
        #expect(viewModel.feeds.isEmpty == false)
        #expect(viewModel.feeds.count == 20) // 기본 20개
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Test: 페이지네이션

    @Test("다음 페이지를 로드하면 기존 Feed에 추가된다")
    func loadMoreFeeds() async throws {
        // Given
        let mockUseCase = MockFetchFeedsUseCase()
        let mockRepository = MockFeedRepositoryForViewModel()
        let mockRouter = NavigationRouter()
        let viewModel = FeedViewModel(navigationRouter: mockRouter, fetchFeedsUseCase: mockUseCase, feedRepository: mockRepository)
        await viewModel.loadFeeds()
        let initialCount = viewModel.feeds.count

        // When: 다음 페이지 로드
        await viewModel.loadMoreFeeds()

        // Then: Feed가 추가되어야 함
        #expect(viewModel.feeds.count > initialCount)
        #expect(viewModel.feeds.count == initialCount + 20)
    }

    @Test("이미 로딩 중이면 중복 로드하지 않는다")
    func preventDuplicateLoading() async throws {
        // Given
        let mockUseCase = MockFetchFeedsUseCase()
        let mockRepository = MockFeedRepositoryForViewModel()
        let mockRouter = NavigationRouter()
        let viewModel = FeedViewModel(navigationRouter: mockRouter, fetchFeedsUseCase: mockUseCase, feedRepository: mockRepository)

        // When: 동시에 여러 번 호출
        async let load1 = viewModel.loadFeeds()
        async let load2 = viewModel.loadFeeds()
        await load1
        await load2

        // Then: 중복 호출되지 않아야 함
        #expect(viewModel.feeds.count == 20) // 한 번만 로드됨
    }

    // MARK: - Test: 필터링

    @Test("스타일 필터를 적용하면 Feed를 새로 로드한다")
    func applyStyleFilter() async throws {
        // Given
        let mockUseCase = MockFetchFeedsUseCase()
        let mockRepository = MockFeedRepositoryForViewModel()
        let mockRouter = NavigationRouter()
        let viewModel = FeedViewModel(navigationRouter: mockRouter, fetchFeedsUseCase: mockUseCase, feedRepository: mockRepository)
        await viewModel.loadFeeds()

        // When: 스타일 필터 적용
        viewModel.selectedStyleIds = [1, 2]
        await viewModel.applyFilters()

        // Then: 필터가 적용된 Feed를 받아야 함
        #expect(viewModel.feeds.isEmpty == false)
        #expect(mockUseCase.lastStyleIds == [1, 2])
    }

    @Test("팔로잉 필터를 적용하면 팔로잉한 사용자의 Feed만 보인다")
    func applyFollowingFilter() async throws {
        // Given
        let mockUseCase = MockFetchFeedsUseCase()
        let mockRepository = MockFeedRepositoryForViewModel()
        let mockRouter = NavigationRouter()
        let viewModel = FeedViewModel(navigationRouter: mockRouter, fetchFeedsUseCase: mockUseCase, feedRepository: mockRepository)

        // When: 팔로잉 필터 적용
        viewModel.followingOnly = true
        await viewModel.applyFilters()

        // Then
        #expect(mockUseCase.lastFollowingOnly == true)
    }

    @Test("새로고침하면 첫 페이지부터 다시 로드한다")
    func refreshFeeds() async throws {
        // Given
        let mockUseCase = MockFetchFeedsUseCase()
        let mockRepository = MockFeedRepositoryForViewModel()
        let mockRouter = NavigationRouter()
        let viewModel = FeedViewModel(navigationRouter: mockRouter, fetchFeedsUseCase: mockUseCase, feedRepository: mockRepository)
        await viewModel.loadFeeds()
        await viewModel.loadMoreFeeds() // 2페이지까지 로드

        // When: 새로고침
        await viewModel.refresh()

        // Then: 첫 페이지만 있어야 함
        #expect(viewModel.feeds.count == 20)
        #expect(mockUseCase.lastPage == 1)
    }

    // MARK: - Test: 로딩 상태

    @Test("로딩 중에는 isLoading이 true다")
    func loadingState() async throws {
        // Given
        let mockUseCase = MockSlowFetchFeedsUseCase()
        let mockRepository = MockFeedRepositoryForViewModel()
        let mockRouter = NavigationRouter()
        let viewModel = FeedViewModel(navigationRouter: mockRouter, fetchFeedsUseCase: mockUseCase, feedRepository: mockRepository)

        // When: 비동기 로딩 시작
        let loadTask = Task {
            await viewModel.loadFeeds()
        }

        // Then: 로딩 중
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초 대기
        #expect(viewModel.isLoading == true)

        await loadTask.value
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Test: 에러 처리

    @Test("UseCase에서 에러가 발생하면 errorMessage가 설정된다")
    func handleError() async throws {
        // Given
        let mockUseCase = MockFailingFetchFeedsUseCase()
        let mockRepository = MockFeedRepositoryForViewModel()
        let mockRouter = NavigationRouter()
        let viewModel = FeedViewModel(navigationRouter: mockRouter, fetchFeedsUseCase: mockUseCase, feedRepository: mockRepository)

        // When
        await viewModel.loadFeeds()

        // Then
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.feeds.isEmpty)
    }

    // MARK: - Test: 좋아요 토글

    @Test("좋아요를 누르면 isLiked가 즉시 토글된다 (낙관적 업데이트)")
    func toggleLike_OptimisticUpdate() async throws {
        // Given
        let mockUseCase = MockFetchFeedsUseCase()
        let mockRepository = MockFeedRepositoryForToggle()
        let mockRouter = NavigationRouter()
        let viewModel = FeedViewModel(navigationRouter: mockRouter, fetchFeedsUseCase: mockUseCase, feedRepository: mockRepository)
        await viewModel.loadFeeds()

        let firstFeed = viewModel.feeds.first!
        let initialLiked = firstFeed.isLiked ?? false

        // When: 좋아요 토글
        await viewModel.toggleLike(feedId: firstFeed.id)

        // Then: isLiked가 토글되어야 함
        let updatedFeed = viewModel.feeds.first!
        #expect(updatedFeed.isLiked == !initialLiked)
        #expect(mockRepository.toggledFeedIds.contains(firstFeed.id))
    }

    @Test("좋아요 실패 시 원래 상태로 롤백된다")
    func toggleLike_RollbackOnFailure() async throws {
        // Given
        let mockUseCase = MockFetchFeedsUseCase()
        let mockRepository = MockFailingFeedRepositoryForToggle()
        let mockRouter = NavigationRouter()
        let viewModel = FeedViewModel(navigationRouter: mockRouter, fetchFeedsUseCase: mockUseCase, feedRepository: mockRepository)
        await viewModel.loadFeeds()

        let firstFeed = viewModel.feeds.first!
        let initialLiked = firstFeed.isLiked ?? false

        // When: 좋아요 토글 (실패)
        await viewModel.toggleLike(feedId: firstFeed.id)

        // Then: 원래 상태로 롤백되어야 함
        let updatedFeed = viewModel.feeds.first!
        #expect(updatedFeed.isLiked == initialLiked) // 원래대로
        #expect(viewModel.errorMessage != nil) // 에러 메시지 표시
    }

    @Test("여러 Feed의 좋아요를 독립적으로 토글할 수 있다")
    func toggleLike_MultipleFeeds() async throws {
        // Given
        let mockUseCase = MockFetchFeedsUseCase()
        let mockRepository = MockFeedRepositoryForToggle()
        let mockRouter = NavigationRouter()
        let viewModel = FeedViewModel(navigationRouter: mockRouter, fetchFeedsUseCase: mockUseCase, feedRepository: mockRepository)
        await viewModel.loadFeeds()

        let feed1 = viewModel.feeds[0]
        let feed2 = viewModel.feeds[1]

        // When: 두 Feed에 좋아요
        await viewModel.toggleLike(feedId: feed1.id)
        await viewModel.toggleLike(feedId: feed2.id)

        // Then: 각각 토글되어야 함
        #expect(mockRepository.toggledFeedIds.contains(feed1.id))
        #expect(mockRepository.toggledFeedIds.contains(feed2.id))
    }
}

// MARK: - Mock FetchFeedsUseCase (테스트용)

/// 정상 동작하는 Mock UseCase
final class MockFetchFeedsUseCase: FetchFeedsUseCase {
    var lastPage: Int = 0
    var lastLimit: Int = 0
    var lastStyleIds: [Int]?
    var lastSituationIds: [Int]?
    var lastFollowingOnly: Bool = false

    func execute(
        page: Int,
        limit: Int,
        styleIds: [Int]?,
        situationIds: [Int]?,
        followingOnly: Bool
    ) async throws -> [Feed] {
        // 호출된 파라미터 기록
        lastPage = page
        lastLimit = limit
        lastStyleIds = styleIds
        lastSituationIds = situationIds
        lastFollowingOnly = followingOnly

        // Mock Feed 생성
        let startId = (page - 1) * limit + 1
        return (0..<limit).map { index in
            let feedId = startId + index
            return Feed(
                id: feedId,
                content: "Feed \(feedId)",
                author: User(
                    id: "user\(feedId)",
                    nickname: "유저\(feedId)",
                    profileImageUrl: nil,
                    isFollowing: feedId % 2 == 0
                ),
                images: [FeedImage(imageUrl: "https://example.com/\(feedId).jpg")],
                styleIds: [1, 2],
                likeCount: 10,
                isLiked: false,
                commentCount: 5
            )
        }
    }
}

/// 느리게 응답하는 Mock UseCase (로딩 상태 테스트용)
final class MockSlowFetchFeedsUseCase: FetchFeedsUseCase {
    func execute(
        page: Int,
        limit: Int,
        styleIds: [Int]?,
        situationIds: [Int]?,
        followingOnly: Bool
    ) async throws -> [Feed] {
        // 1초 지연
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return []
    }
}

/// 에러를 발생시키는 Mock UseCase
final class MockFailingFetchFeedsUseCase: FetchFeedsUseCase {
    func execute(
        page: Int,
        limit: Int,
        styleIds: [Int]?,
        situationIds: [Int]?,
        followingOnly: Bool
    ) async throws -> [Feed] {
        throw FeedError.networkError
    }
}

// MARK: - Mock FeedRepository (ViewModel 테스트용)

final class MockFeedRepositoryForViewModel: FeedRepository {
    func fetchFeeds(page: Int, limit: Int, styleIds: [Int]?, situationIds: [Int]?, followingOnly: Bool) async throws -> [Feed] {
        return []
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        throw FeedDataSourceError.notFound
    }

    func toggleLike(feedId: Int) async throws {
        // Mock: 아무것도 하지 않음
    }
}

/// 좋아요 토글을 기록하는 Mock Repository
final class MockFeedRepositoryForToggle: FeedRepository {
    var toggledFeedIds: [Int] = []

    func fetchFeeds(page: Int, limit: Int, styleIds: [Int]?, situationIds: [Int]?, followingOnly: Bool) async throws -> [Feed] {
        return []
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        throw FeedDataSourceError.notFound
    }

    func toggleLike(feedId: Int) async throws {
        toggledFeedIds.append(feedId)
    }
}

/// 좋아요 실패하는 Mock Repository
final class MockFailingFeedRepositoryForToggle: FeedRepository {
    func fetchFeeds(page: Int, limit: Int, styleIds: [Int]?, situationIds: [Int]?, followingOnly: Bool) async throws -> [Feed] {
        let startId = 1
        let limit = 20
        return (0..<limit).map { index in
            let feedId = startId + index
            return Feed(
                id: feedId,
                content: "Feed \(feedId)",
                author: User(
                    id: "user\(feedId)",
                    nickname: "유저\(feedId)",
                    profileImageUrl: nil
                ),
                images: [FeedImage(imageUrl: "https://example.com/\(feedId).jpg")],
                styleIds: [1, 2],
                likeCount: 10,
                isLiked: false,
                commentCount: 5
            )
        }
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        throw FeedDataSourceError.notFound
    }

    func toggleLike(feedId: Int) async throws {
        // 항상 에러 발생
        throw FeedDataSourceError.networkError
    }
}

// MARK: - FeedError (테스트용 에러 타입)

enum FeedError: Error {
    case networkError
    case notFound
}
