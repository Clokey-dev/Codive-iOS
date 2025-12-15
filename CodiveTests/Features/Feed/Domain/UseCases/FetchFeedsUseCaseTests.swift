//
//  FetchFeedsUseCaseTests.swift
//  CodiveTests
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation
import Testing
@testable import Codive

/// FetchFeedsUseCase 동작을 검증하는 테스트
struct FetchFeedsUseCaseTests {

    // MARK: - Test: UseCase가 Repository로부터 Feed 목록을 가져오는지 검증

    @Test("UseCase가 Repository에서 Feed 목록을 성공적으로 가져온다")
    func fetchFeedsSuccessfully() async throws {
        // Given: Mock Repository 준비
        let mockRepository = MockFeedRepository()
        let useCase = DefaultFetchFeedsUseCase(repository: mockRepository)

        // When: UseCase 실행
        let feeds = try await useCase.execute(page: 1, limit: 10, styleIds: nil, situationIds: nil, followingOnly: false)

        // Then: Feed가 반환되어야 함
        #expect(feeds.count == 10)
        #expect(feeds.first?.id == 1)
    }

    // MARK: - Test: 페이지네이션이 제대로 작동하는지 검증

    @Test("다른 페이지 번호로 요청하면 다른 Feed를 반환한다")
    func fetchFeedsWithDifferentPages() async throws {
        // Given
        let mockRepository = MockFeedRepository()
        let useCase = DefaultFetchFeedsUseCase(repository: mockRepository)

        // When: 1페이지와 2페이지 요청
        let page1Feeds = try await useCase.execute(page: 1, limit: 5, styleIds: nil, situationIds: nil, followingOnly: false)
        let page2Feeds = try await useCase.execute(page: 2, limit: 5, styleIds: nil, situationIds: nil, followingOnly: false)

        // Then: 서로 다른 Feed를 반환해야 함
        #expect(page1Feeds.first?.id != page2Feeds.first?.id)
        #expect(page1Feeds.count == 5)
        #expect(page2Feeds.count == 5)
    }

    // MARK: - Test: Repository에서 에러 발생 시 처리

    @Test("Repository에서 에러가 발생하면 에러를 throw 한다")
    func fetchFeedsThrowsError() async throws {
        // Given: 에러를 던지는 Mock Repository
        let mockRepository = MockFeedRepositoryWithError()
        let useCase = DefaultFetchFeedsUseCase(repository: mockRepository)

        // When/Then: 에러가 발생해야 함
        await #expect(throws: FeedError.self) {
            try await useCase.execute(page: 1, limit: 10, styleIds: nil, situationIds: nil, followingOnly: false)
        }
    }
}

// MARK: - Mock FeedRepository (테스트용)

/// 테스트를 위한 Mock FeedRepository
/// 실제 네트워크 호출 없이 가짜 데이터를 반환합니다.
final class MockFeedRepository: FeedRepository {
    func fetchFeeds(page: Int, limit: Int, styleIds: [Int]?, situationIds: [Int]?, followingOnly: Bool) async throws -> [Feed] {
        // 페이지에 따라 다른 시작 ID 사용
        let startId = (page - 1) * limit + 1

        return (0..<limit).map { index in
            let feedId = startId + index
            return Feed(
                id: feedId,
                content: "Test feed content \(feedId)",
                author: nil,
                images: [
                    FeedImage(imageUrl: "https://example.com/image\(feedId).jpg", tags: [])
                ],
                situationId: 1,
                styleIds: [1, 2],
                hashtags: ["#test"],
                createdAt: Date(),
                likeCount: 10,
                isLiked: false,
                commentCount: 5
            )
        }
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        return Feed(
            id: id,
            content: "Test feed detail \(id)",
            author: nil,
            images: [FeedImage(imageUrl: "https://example.com/image\(id).jpg", tags: [])],
            situationId: 1,
            styleIds: [1, 2],
            hashtags: ["#test"],
            createdAt: Date(),
            likeCount: 10,
            isLiked: false,
            commentCount: 5
        )
    }

    func toggleLike(feedId: Int) async throws {
        // Mock: 아무것도 하지 않음
    }
}

/// 에러를 발생시키는 Mock Repository
final class MockFeedRepositoryWithError: FeedRepository {
    func fetchFeeds(page: Int, limit: Int, styleIds: [Int]?, situationIds: [Int]?, followingOnly: Bool) async throws -> [Feed] {
        throw FeedError.networkError
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        throw FeedError.notFound
    }

    func toggleLike(feedId: Int) async throws {
        throw FeedError.networkError
    }
}
