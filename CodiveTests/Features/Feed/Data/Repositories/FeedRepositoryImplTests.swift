//
//  FeedRepositoryImplTests.swift
//  CodiveTests
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation
import Testing
@testable import Codive

/// FeedRepositoryImpl의 동작을 검증하는 테스트
struct FeedRepositoryImplTests {

    // MARK: - Test: Repository가 DataSource로부터 데이터를 가져오는지 검증

    @Test("Repository가 DataSource에서 Feed 목록을 성공적으로 가져온다")
    func fetchFeedsSuccessfully() async throws {
        // Given
        let dataSource = MockFeedDataSource()
        let repository = FeedRepositoryImpl(dataSource: dataSource)

        // When
        let feeds = try await repository.fetchFeeds(page: 1, limit: 10, styleIds: nil, situationIds: nil, followingOnly: false)

        // Then
        #expect(feeds.count == 10)
        #expect(feeds.first?.id == 1)
        #expect(feeds.last?.id == 10)
    }

    // MARK: - Test: 페이지네이션 동작 검증

    @Test("2페이지를 요청하면 11번부터 20번까지 Feed를 반환한다")
    func fetchSecondPage() async throws {
        // Given
        let dataSource = MockFeedDataSource()
        let repository = FeedRepositoryImpl(dataSource: dataSource)

        // When
        let feeds = try await repository.fetchFeeds(page: 2, limit: 10, styleIds: nil, situationIds: nil, followingOnly: false)

        // Then
        #expect(feeds.count == 10)
        #expect(feeds.first?.id == 11)
        #expect(feeds.last?.id == 20)
    }

    // MARK: - Test: Feed 상세 조회

    @Test("Feed ID로 상세 정보를 가져온다")
    func fetchFeedDetail() async throws {
        // Given
        let dataSource = MockFeedDataSource()
        let repository = FeedRepositoryImpl(dataSource: dataSource)
        let feedId = 5

        // When
        let feed = try await repository.fetchFeedDetail(id: feedId)

        // Then
        #expect(feed.id == feedId)
        #expect(feed.content != nil)
        #expect(feed.images.isEmpty == false)
    }

    // MARK: - Test: 마지막 페이지 처리

    @Test("존재하지 않는 페이지를 요청하면 빈 배열을 반환한다")
    func fetchNonExistentPage() async throws {
        // Given
        let dataSource = MockFeedDataSource()
        let repository = FeedRepositoryImpl(dataSource: dataSource)

        // When: 100페이지 요청 (Mock은 30개만 있음)
        let feeds = try await repository.fetchFeeds(page: 100, limit: 10, styleIds: nil, situationIds: nil, followingOnly: false)

        // Then
        #expect(feeds.isEmpty)
    }

    // MARK: - Test: 에러 처리

    @Test("존재하지 않는 Feed ID를 요청하면 에러를 throw 한다")
    func fetchNonExistentFeedDetail() async throws {
        // Given
        let dataSource = MockFeedDataSource()
        let repository = FeedRepositoryImpl(dataSource: dataSource)

        // When/Then
        await #expect(throws: FeedDataSourceError.self) {
            try await repository.fetchFeedDetail(id: 999)
        }
    }

    // MARK: - Test: 필터링

    @Test("스타일 필터링: 특정 스타일의 Feed만 가져온다")
    func fetchFeedsWithStyleFilter() async throws {
        // Given
        let dataSource = MockFeedDataSource()
        let repository = FeedRepositoryImpl(dataSource: dataSource)

        // When: 스타일 1번으로 필터링
        let feeds = try await repository.fetchFeeds(page: 1, limit: 30, styleIds: [1], situationIds: nil, followingOnly: false)

        // Then: 모든 Feed가 스타일 1을 포함해야 함
        for feed in feeds {
            #expect(feed.styleIds?.contains(1) == true)
        }
    }

    @Test("상황 필터링: 특정 상황의 Feed만 가져온다")
    func fetchFeedsWithSituationFilter() async throws {
        // Given
        let dataSource = MockFeedDataSource()
        let repository = FeedRepositoryImpl(dataSource: dataSource)

        // When: 상황 2번으로 필터링
        let feeds = try await repository.fetchFeeds(page: 1, limit: 30, styleIds: nil, situationIds: [2], followingOnly: false)

        // Then: 모든 Feed의 situationId가 2여야 함
        for feed in feeds {
            #expect(feed.situationId == 2)
        }
    }

    @Test("팔로잉 필터링: 팔로잉한 사용자의 Feed만 가져온다")
    func fetchFeedsWithFollowingFilter() async throws {
        // Given
        let dataSource = MockFeedDataSource()
        let repository = FeedRepositoryImpl(dataSource: dataSource)

        // When: 팔로잉만 필터링
        let feeds = try await repository.fetchFeeds(page: 1, limit: 30, styleIds: nil, situationIds: nil, followingOnly: true)

        // Then: 모든 Feed의 작성자가 팔로잉 상태여야 함
        for feed in feeds {
            #expect(feed.author.isFollowing == true)
        }
    }

    @Test("복합 필터링: 스타일 + 상황 + 팔로잉 동시 적용")
    func fetchFeedsWithMultipleFilters() async throws {
        // Given
        let dataSource = MockFeedDataSource()
        let repository = FeedRepositoryImpl(dataSource: dataSource)

        // When: 여러 필터 동시 적용
        let feeds = try await repository.fetchFeeds(
            page: 1,
            limit: 30,
            styleIds: [1, 2],
            situationIds: [1],
            followingOnly: true
        )

        // Then: 모든 조건을 만족해야 함
        for feed in feeds {
            let hasMatchingStyle = feed.styleIds?.contains(where: { [1, 2].contains($0) }) == true
            #expect(hasMatchingStyle)
            #expect(feed.situationId == 1)
            #expect(feed.author.isFollowing == true)
        }
    }
}
