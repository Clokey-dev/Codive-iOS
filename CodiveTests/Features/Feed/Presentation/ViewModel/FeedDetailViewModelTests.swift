//
//  FeedDetailViewModelTests.swift
//  CodiveTests
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation
import Testing
@testable import Codive

/// FeedDetailViewModel의 동작을 검증하는 테스트
@MainActor
struct FeedDetailViewModelTests {

    // MARK: - Test: Feed 상세 로딩

    @Test("ViewModel 생성 시 자동으로 Feed 상세를 로드한다")
    func loadFeedDetail() async throws {
        // Given
        let mockUseCase = MockFetchFeedDetailUseCase()
        let mockRepository = MockFeedRepositoryForDetailViewModel()
        let viewModel = FeedDetailViewModel(
            feedId: 1,
            fetchFeedDetailUseCase: mockUseCase,
            feedRepository: mockRepository
        )

        // When: 초기 로딩
        await viewModel.loadFeedDetail()

        // Then
        #expect(viewModel.feed != nil)
        #expect(viewModel.feed?.id == 1)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("존재하지 않는 Feed ID로 로드하면 에러가 발생한다")
    func loadNonExistentFeed() async throws {
        // Given
        let mockUseCase = MockFetchFeedDetailUseCase()
        let mockRepository = MockFeedRepositoryForDetailViewModel()
        let viewModel = FeedDetailViewModel(
            feedId: 999,
            fetchFeedDetailUseCase: mockUseCase,
            feedRepository: mockRepository
        )

        // When
        await viewModel.loadFeedDetail()

        // Then
        #expect(viewModel.feed == nil)
        #expect(viewModel.errorMessage != nil)
    }

    @Test("로딩 중에는 isLoading이 true다")
    func loadingState() async throws {
        // Given
        let mockUseCase = MockSlowFetchFeedDetailUseCase()
        let mockRepository = MockFeedRepositoryForDetailViewModel()
        let viewModel = FeedDetailViewModel(
            feedId: 1,
            fetchFeedDetailUseCase: mockUseCase,
            feedRepository: mockRepository
        )

        // When: 비동기 로딩 시작
        let loadTask = Task {
            await viewModel.loadFeedDetail()
        }

        // Then: 로딩 중
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초 대기
        #expect(viewModel.isLoading == true)

        await loadTask.value
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Test: 좋아요 토글

    @Test("좋아요를 누르면 isLiked가 즉시 토글된다 (낙관적 업데이트)")
    func toggleLike_OptimisticUpdate() async throws {
        // Given
        let mockUseCase = MockFetchFeedDetailUseCase()
        let mockRepository = MockFeedRepositoryForToggleInDetail()
        let viewModel = FeedDetailViewModel(
            feedId: 1,
            fetchFeedDetailUseCase: mockUseCase,
            feedRepository: mockRepository
        )
        await viewModel.loadFeedDetail()

        let initialLiked = viewModel.feed?.isLiked ?? false

        // When: 좋아요 토글
        await viewModel.toggleLike()

        // Then: isLiked가 토글되어야 함
        #expect(viewModel.feed?.isLiked == !initialLiked)
        #expect(mockRepository.toggledFeedIds.contains(1))
    }

    @Test("좋아요를 누르면 likeCount도 함께 증가/감소한다")
    func toggleLike_UpdateCount() async throws {
        // Given
        let mockUseCase = MockFetchFeedDetailUseCase()
        let mockRepository = MockFeedRepositoryForToggleInDetail()
        let viewModel = FeedDetailViewModel(
            feedId: 1,
            fetchFeedDetailUseCase: mockUseCase,
            feedRepository: mockRepository
        )
        await viewModel.loadFeedDetail()

        let initialCount = viewModel.feed?.likeCount ?? 0
        let initialLiked = viewModel.feed?.isLiked ?? false

        // When: 좋아요 토글
        await viewModel.toggleLike()

        // Then: count가 변경되어야 함
        if !initialLiked {
            // 좋아요 추가
            #expect(viewModel.feed?.likeCount == initialCount + 1)
        } else {
            // 좋아요 취소
            #expect(viewModel.feed?.likeCount == initialCount - 1)
        }
    }

    @Test("좋아요 실패 시 원래 상태로 롤백된다")
    func toggleLike_RollbackOnFailure() async throws {
        // Given
        let mockUseCase = MockFetchFeedDetailUseCase()
        let mockRepository = MockFailingFeedRepositoryForToggleInDetail()
        let viewModel = FeedDetailViewModel(
            feedId: 1,
            fetchFeedDetailUseCase: mockUseCase,
            feedRepository: mockRepository
        )
        await viewModel.loadFeedDetail()

        let initialLiked = viewModel.feed?.isLiked ?? false
        let initialCount = viewModel.feed?.likeCount ?? 0

        // When: 좋아요 토글 (실패)
        await viewModel.toggleLike()

        // Then: 원래 상태로 롤백되어야 함
        #expect(viewModel.feed?.isLiked == initialLiked)
        #expect(viewModel.feed?.likeCount == initialCount)
        #expect(viewModel.errorMessage != nil) // 에러 메시지 표시
    }

}

// MARK: - Mock FetchFeedDetailUseCase

final class MockFetchFeedDetailUseCase: FetchFeedDetailUseCase {
    func execute(feedId: Int) async throws -> Feed {
        guard feedId < 100 else {
            throw FeedDetailViewModelError.notFound
        }

        return Feed(
            id: feedId,
            content: "Feed #\(feedId) 상세 내용입니다.",
            author: User(
                id: "user\(feedId)",
                nickname: "유저\(feedId)",
                profileImageUrl: "https://example.com/profile.jpg"
            ),
            images: [
                FeedImage(imageUrl: "https://example.com/image1.jpg"),
                FeedImage(imageUrl: "https://example.com/image2.jpg"),
                FeedImage(imageUrl: "https://example.com/image3.jpg")
            ],
            situationId: 1,
            styleIds: [1, 2],
            hashtags: ["#패션", "#데일리룩"],
            createdAt: Date(),
            likeCount: 42,
            isLiked: false,
            commentCount: 15
        )
    }
}

final class MockSlowFetchFeedDetailUseCase: FetchFeedDetailUseCase {
    func execute(feedId: Int) async throws -> Feed {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 지연
        throw FeedDetailViewModelError.notFound
    }
}

// MARK: - Mock FeedRepository (ViewModel 테스트용)

final class MockFeedRepositoryForDetailViewModel: FeedRepository {
    func fetchFeeds(page: Int, limit: Int, styleIds: [Int]?, situationIds: [Int]?, followingOnly: Bool) async throws -> [Feed] {
        return []
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        throw FeedDetailViewModelError.notFound
    }

    func toggleLike(feedId: Int) async throws {
        // Mock
    }
}

final class MockFeedRepositoryForToggleInDetail: FeedRepository {
    var toggledFeedIds: [Int] = []

    func fetchFeeds(page: Int, limit: Int, styleIds: [Int]?, situationIds: [Int]?, followingOnly: Bool) async throws -> [Feed] {
        return []
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        throw FeedDetailViewModelError.notFound
    }

    func toggleLike(feedId: Int) async throws {
        toggledFeedIds.append(feedId)
    }
}

final class MockFailingFeedRepositoryForToggleInDetail: FeedRepository {
    func fetchFeeds(page: Int, limit: Int, styleIds: [Int]?, situationIds: [Int]?, followingOnly: Bool) async throws -> [Feed] {
        return []
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        throw FeedDetailViewModelError.notFound
    }

    func toggleLike(feedId: Int) async throws {
        throw FeedDetailViewModelError.networkError
    }
}

// MARK: - FeedDetailViewModelError

enum FeedDetailViewModelError: Error {
    case networkError
    case notFound
}
