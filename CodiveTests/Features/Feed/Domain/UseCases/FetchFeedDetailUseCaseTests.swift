//
//  FetchFeedDetailUseCaseTests.swift
//  CodiveTests
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation
import Testing
@testable import Codive

/// FetchFeedDetailUseCase의 동작을 검증하는 테스트
struct FetchFeedDetailUseCaseTests {

    // MARK: - Test: Feed 상세 조회

    @Test("UseCase가 Repository에서 Feed 상세를 성공적으로 가져온다")
    func fetchFeedDetailSuccessfully() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForDetailUseCase()
        let useCase = DefaultFetchFeedDetailUseCase(repository: mockRepository)

        // When
        let feed = try await useCase.execute(feedId: 1)

        // Then
        #expect(feed.id == 1)
        #expect(feed.content != nil)
        #expect(feed.author != nil)
        #expect(feed.images.isEmpty == false)
        #expect(feed.likeCount != nil)
        #expect(feed.commentCount != nil)
    }

    @Test("존재하지 않는 Feed ID는 에러를 발생시킨다")
    func fetchNonExistentFeed() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForDetailUseCase()
        let useCase = DefaultFetchFeedDetailUseCase(repository: mockRepository)

        // When & Then
        await #expect(throws: FeedDetailUseCaseError.self) {
            try await useCase.execute(feedId: 999)
        }
    }

    @Test("Repository 에러가 발생하면 UseCase도 에러를 전파한다")
    func propagateRepositoryError() async throws {
        // Given
        let mockRepository = MockFailingFeedRepositoryForDetailUseCase()
        let useCase = DefaultFetchFeedDetailUseCase(repository: mockRepository)

        // When & Then
        await #expect(throws: Error.self) {
            try await useCase.execute(feedId: 1)
        }
    }

    @Test("Repository에 올바른 feedId를 전달한다")
    func passCorrectFeedId() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForDetailUseCase()
        let useCase = DefaultFetchFeedDetailUseCase(repository: mockRepository)

        // When
        let feed = try await useCase.execute(feedId: 42)

        // Then
        #expect(feed.id == 42)
        #expect(mockRepository.lastFetchedId == 42)
    }
}

// MARK: - Mock FeedRepository (UseCase 테스트용)

final class MockFeedRepositoryForDetailUseCase: FeedRepository {
    var lastFetchedId: Int?

    func fetchFeeds(page: Int, limit: Int, styleIds: [Int]?, situationIds: [Int]?, followingOnly: Bool) async throws -> [Feed] {
        return []
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        lastFetchedId = id

        guard id < 100 else {
            throw FeedDetailUseCaseError.notFound
        }

        return Feed(
            id: id,
            content: "Feed #\(id) 상세 내용",
            author: User(
                id: "user\(id)",
                nickname: "유저\(id)",
                profileImageUrl: "https://example.com/profile.jpg"
            ),
            images: [
                FeedImage(imageUrl: "https://example.com/image1.jpg"),
                FeedImage(imageUrl: "https://example.com/image2.jpg")
            ],
            situationId: 1,
            styleIds: [1, 2],
            hashtags: ["#패션", "#데일리"],
            createdAt: Date(),
            likeCount: 50,
            isLiked: false,
            commentCount: 20
        )
    }

    func toggleLike(feedId: Int) async throws {
        // Mock
    }
}

/// 에러를 발생시키는 Mock Repository
final class MockFailingFeedRepositoryForDetailUseCase: FeedRepository {
    func fetchFeeds(page: Int, limit: Int, styleIds: [Int]?, situationIds: [Int]?, followingOnly: Bool) async throws -> [Feed] {
        return []
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        throw FeedDetailUseCaseError.networkError
    }

    func toggleLike(feedId: Int) async throws {
        // Mock
    }
}

// MARK: - FeedDetailUseCaseError

enum FeedDetailUseCaseError: Error {
    case networkError
    case notFound
}
