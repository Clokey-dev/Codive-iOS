//
//  FeedDataSource.swift
//  Codive
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation

/// Feed 데이터를 가져오는 DataSource 프로토콜
protocol FeedDataSource {
    /// Feed 목록을 페이지 단위로 가져옵니다.
    func fetchFeeds(
        page: Int,
        limit: Int,
        styleIds: [Int]?,
        situationIds: [Int]?,
        followingOnly: Bool
    ) async throws -> [Feed]

    /// 특정 Feed의 상세 정보를 가져옵니다.
    func fetchFeedDetail(id: Int) async throws -> Feed

    /// Feed의 좋아요를 토글합니다.
    func toggleLike(feedId: Int) async throws
}

/// Mock FeedDataSource - 서버 연결 전 테스트용 구현
final class MockFeedDataSource: FeedDataSource {

    /// Mock 데이터 저장소
    private let mockFeeds: [Feed]

    init() {
        // 샘플 Feed 데이터 30개 생성
        self.mockFeeds = (1...30).map { id in
            Self.createMockFeed(id: id)
        }
    }

    /// Mock Feed 생성 헬퍼 메서드
    private static func createMockFeed(id: Int) -> Feed {
        // id가 짝수면 팔로잉한 사용자로 설정
        let isFollowing = id % 2 == 0

        let author = User(
            id: "user\(id % 5 + 1)",
            nickname: "유저\(id % 5 + 1)",
            profileImageUrl: "https://example.com/profile\(id % 5 + 1).jpg",
            bio: "안녕하세요! 패션을 사랑하는 유저입니다 ✨",
            isFollowing: isFollowing
        )

        let tags = [
            ImageClothTag(clothId: id, locationX: 0.3, locationY: 0.4),
            ImageClothTag(clothId: id + 100, locationX: 0.5, locationY: 0.6)
        ]

        let images = [
            FeedImage(
                imageUrl: "https://picsum.photos/400/600?random=\(id)",
                tags: tags
            )
        ]

        return Feed(
            id: id,
            content: "오늘의 OOTD #\(id) 🎨\n날씨가 좋아서 가벼운 옷차림으로 나왔어요!",
            author: author,
            images: images,
            situationId: (id % 3) + 1,
            styleIds: [(id % 10) + 1, ((id + 1) % 10) + 1],
            hashtags: ["#OOTD", "#fashion", "#daily"],
            createdAt: Date().addingTimeInterval(-Double(id * 3600)),
            likeCount: Int.random(in: 0...500), // 상세 조회용
            isLiked: Bool.random(),
            commentCount: Int.random(in: 0...50)
        )
    }

    func fetchFeeds(
        page: Int,
        limit: Int,
        styleIds: [Int]? = nil,
        situationIds: [Int]? = nil,
        followingOnly: Bool = false
    ) async throws -> [Feed] {
        // 네트워크 지연 시뮬레이션
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초

        // 필터링 적용
        var filteredFeeds = mockFeeds

        // 스타일 필터 (Feed의 styleIds 중 하나라도 필터에 포함되면 표시)
        if let styleIds = styleIds, !styleIds.isEmpty {
            filteredFeeds = filteredFeeds.filter { feed in
                guard let feedStyleIds = feed.styleIds else { return false }
                return !Set(feedStyleIds).isDisjoint(with: Set(styleIds))
            }
        }

        // 상황 필터 (Feed의 situationId가 필터에 포함되면 표시)
        if let situationIds = situationIds, !situationIds.isEmpty {
            filteredFeeds = filteredFeeds.filter { feed in
                guard let feedSituationId = feed.situationId else { return false }
                return situationIds.contains(feedSituationId)
            }
        }

        // 팔로잉 필터
        if followingOnly {
            filteredFeeds = filteredFeeds.filter { $0.author?.isFollowing == true }
        }

        // 페이지네이션
        let startIndex = (page - 1) * limit
        let endIndex = min(startIndex + limit, filteredFeeds.count)

        guard startIndex < filteredFeeds.count else {
            return []
        }

        return Array(filteredFeeds[startIndex..<endIndex])
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        // 네트워크 지연 시뮬레이션
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3초

        guard let feed = mockFeeds.first(where: { $0.id == id }) else {
            throw FeedDataSourceError.notFound
        }

        return feed
    }

    func toggleLike(feedId: Int) async throws {
        // 네트워크 지연 시뮬레이션
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2초

        // Mock: 실제로는 서버에 POST 요청
        print("✅ Toggled like for feed \(feedId)")
    }
}

// MARK: - FeedDataSourceError

enum FeedDataSourceError: Error {
    case notFound
    case networkError
    case invalidResponse
}
