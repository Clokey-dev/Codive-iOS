//
//  FeedDataSource.swift
//  Codive
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation

/// Feed 페이지네이션 결과
struct FeedPageResult {
    let feeds: [Feed]
    let nextCursor: String?
    let hasNext: Bool
}

/// Feed 데이터를 가져오는 DataSource 프로토콜
protocol FeedDataSource {
    /// Feed 목록 조회 (커서 기반 페이지네이션)
    func fetchFeeds(
        cursor: String?,
        limit: Int,
        styleIds: [Int]?,
        situationIds: [Int]?,
        followingOnly: Bool
    ) async throws -> FeedPageResult

    /// 특정 Feed의 상세 정보 조회
    func fetchFeedDetail(id: Int) async throws -> Feed

    /// Feed의 좋아요 토글
    func toggleLike(feedId: Int) async throws

    /// 특정 Feed를 좋아한 사용자 목록 조회
    func fetchLikers(feedId: Int) async throws -> [User]
}

// MARK: - DefaultFeedDataSource

final class DefaultFeedDataSource: FeedDataSource {

    private let apiService: FeedAPIServiceProtocol
    private let historyAPIService: HistoryAPIServiceProtocol

    init(
        apiService: FeedAPIServiceProtocol = FeedAPIService(),
        historyAPIService: HistoryAPIServiceProtocol = HistoryAPIService()
    ) {
        self.apiService = apiService
        self.historyAPIService = historyAPIService
    }

    func fetchFeeds(
        cursor: String?,
        limit: Int,
        styleIds: [Int]?,
        situationIds: [Int]?,
        followingOnly: Bool
    ) async throws -> FeedPageResult {
        let result = try await apiService.fetchFeeds(
            cursor: cursor,
            size: Int32(limit),
            styleIds: styleIds?.map { Int64($0) },
            situationIds: situationIds?.map { Int64($0) },
            followScope: followingOnly ? .following : .all
        )

        let feeds = result.feeds.map { $0.toDomain() }
        return FeedPageResult(
            feeds: feeds,
            nextCursor: result.nextCursor,
            hasNext: result.hasNext
        )
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        let dto = try await historyAPIService.fetchHistoryDetail(historyId: Int64(id))
        return dto.toDomain(feedId: id)
    }

    func toggleLike(feedId: Int) async throws {
        try await apiService.toggleLike(historyId: Int64(feedId))
    }

    func fetchLikers(feedId: Int) async throws -> [User] {
        let result = try await apiService.fetchLikers(
            historyId: Int64(feedId),
            lastLikeId: nil,
            size: 100
        )
        return result.likers.map { $0.toDomain() }
    }
}

// MARK: - DTO Mapping

private extension FeedItemDTO {
    func toDomain() -> Feed {
        return Feed(
            id: Int(feedId),
            content: nil,
            author: author.toDomain(),
            images: imageUrl.map { [FeedImage(imageUrl: $0)] } ?? [],
            situationId: nil,
            styleIds: nil,
            hashtags: nil,
            createdAt: createdAt,
            likeCount: nil,
            isLiked: isLiked,
            commentCount: nil
        )
    }
}

private extension FeedAuthorDTO {
    func toDomain() -> User {
        return User(
            id: String(memberId),
            nickname: nickname ?? "",
            profileImageUrl: profileImageUrl,
            isFollowing: isFollowing,
            isMe: false
        )
    }
}

private extension LikerDTO {
    func toDomain() -> User {
        return User(
            id: String(memberId),
            nickname: nickname ?? "",
            profileImageUrl: profileImageUrl,
            isFollowing: isFollowing
        )
    }
}

extension HistoryDetailDTO {
    private static let iso8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return formatter
    }()

    func toDomain(feedId: Int) -> Feed {
        let author = User(
            id: String(memberId),
            nickname: nickname ?? "",
            profileImageUrl: profileImageUrl,
            isMe: isMine
        )

        let feedImages = images.map { img in
            FeedImage(imageId: img.imageId, imageUrl: img.imageUrl)
        }

        let styleIds = styles.map { Int($0.styleId) }
        let styleNames = styles.map { $0.styleName }

        // historyDate를 Date로 변환
        let createdAtDate = historyDate.flatMap { Self.iso8601DateFormatter.date(from: $0) }

        return Feed(
            id: feedId,
            content: content,
            author: author,
            images: feedImages,
            situationId: situationId.map { Int($0) },
            styleIds: styleIds.isEmpty ? nil : styleIds,
            styleNames: styleNames.isEmpty ? nil : styleNames,
            hashtags: hashtags,
            createdAt: createdAtDate,
            likeCount: Int(likeCount),
            isLiked: isLiked,
            commentCount: Int(commentCount)
        )
    }
}

/// Mock FeedDataSource - 서버 연결 전 테스트용 구현
final class MockFeedDataSource: FeedDataSource {

    /// Mock 데이터 저장소
    private var mockFeeds: [Feed]

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
            bio: "안녕하세요! 패션을 사랑하는 유저입니다",
            isFollowing: isFollowing
        )

        // 첫 번째 이미지 태그
        let tags1 = [
            ImageClothTag(clothId: id, locationX: 0.3, locationY: 0.4),
            ImageClothTag(clothId: id + 100, locationX: 0.5, locationY: 0.6)
        ]

        // 두 번째 이미지 태그
        let tags2 = [
            ImageClothTag(clothId: id + 200, locationX: 0.25, locationY: 0.35),
            ImageClothTag(clothId: id + 300, locationX: 0.7, locationY: 0.5)
        ]

        // 세 번째 이미지 태그
        let tags3 = [
            ImageClothTag(clothId: id + 400, locationX: 0.4, locationY: 0.3),
            ImageClothTag(clothId: id + 500, locationX: 0.6, locationY: 0.65)
        ]

        let images = [
            FeedImage(
                imageUrl: "https://picsum.photos/400/600?random=\(id)",
                tags: tags1
            ),
            FeedImage(
                imageUrl: "https://picsum.photos/400/600?random=\(id + 1000)",
                tags: tags2
            ),
            FeedImage(
                imageUrl: "https://picsum.photos/400/600?random=\(id + 2000)",
                tags: tags3
            )
        ]

        return Feed(
            id: id,
            content: "오늘의 OOTD #\(id)\n날씨가 좋아서 가벼운 옷차림으로 나왔어요!",
            author: author,
            images: images,
            situationId: (id % 3) + 1,
            styleIds: [(id % 10) + 1, ((id + 1) % 10) + 1],
            styleNames: ["캐주얼", "스트릿"],
            hashtags: ["#OOTD", "#fashion", "#daily"],
            createdAt: Date().addingTimeInterval(-Double(id * 3600)),
            likeCount: Int.random(in: 0...500),
            isLiked: Bool.random(),
            commentCount: Int.random(in: 0...50)
        )
    }

    func fetchFeeds(
        cursor: String?,
        limit: Int,
        styleIds: [Int]? = nil,
        situationIds: [Int]? = nil,
        followingOnly: Bool = false
    ) async throws -> FeedPageResult {
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
            filteredFeeds = filteredFeeds.filter { $0.author.isFollowing == true }
        }

        // 커서 기반 페이지네이션 (Mock: cursor = lastFeedId)
        var startIndex = 0
        if let cursor = cursor, let lastId = Int(cursor) {
            if let index = filteredFeeds.firstIndex(where: { $0.id == lastId }) {
                startIndex = index + 1
            }
        }

        let endIndex = min(startIndex + limit, filteredFeeds.count)

        if startIndex >= filteredFeeds.count {
            return FeedPageResult(feeds: [], nextCursor: nil, hasNext: false)
        }

        let pageFeeds = Array(filteredFeeds[startIndex..<endIndex])
        let hasNext = endIndex < filteredFeeds.count
        let nextCursor = hasNext ? String(pageFeeds.last?.id ?? 0) : nil

        return FeedPageResult(feeds: pageFeeds, nextCursor: nextCursor, hasNext: hasNext)
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

        guard let index = mockFeeds.firstIndex(where: { $0.id == feedId }) else {
            throw FeedDataSourceError.notFound
        }

        let oldFeed = mockFeeds[index]
        let newIsLiked = !(oldFeed.isLiked ?? false)
        let newLikeCount = max(0, (oldFeed.likeCount ?? 0) + (newIsLiked ? 1 : -1))

        let newFeed = Feed(
            id: oldFeed.id,
            content: oldFeed.content,
            author: oldFeed.author,
            images: oldFeed.images,
            situationId: oldFeed.situationId,
            styleIds: oldFeed.styleIds,
            styleNames: oldFeed.styleNames,
            hashtags: oldFeed.hashtags,
            createdAt: oldFeed.createdAt,
            likeCount: newLikeCount,
            isLiked: newIsLiked,
            commentCount: oldFeed.commentCount
        )

        mockFeeds[index] = newFeed

        #if DEBUG
        print("[MockFeed] Toggled like for feed \(feedId): isLiked=\(newIsLiked), likeCount=\(newLikeCount)")
        #endif
    }
    
    func fetchLikers(feedId: Int) async throws -> [User] {
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        return [
            .init(id: "1", nickname: "패셔니스타", profileImageUrl: nil),
            .init(id: "2", nickname: "코디장인", profileImageUrl: nil),
            .init(id: "3", nickname: "스타일헌터", profileImageUrl: nil),
            .init(id: "4", nickname: "옷잘알", profileImageUrl: nil),
            .init(id: "5", nickname: "데일리룩장인", profileImageUrl: nil)
        ]
    }
}

// MARK: - FeedDataSourceError

enum FeedDataSourceError: Error {
    case notFound
    case networkError
    case invalidResponse
}

#if DEBUG
/// 프리뷰용 빈 DataSource
final class EmptyFeedDataSource: FeedDataSource {
    func fetchFeeds(
        cursor: String?,
        limit: Int,
        styleIds: [Int]?,
        situationIds: [Int]?,
        followingOnly: Bool
    ) async throws -> FeedPageResult {
        FeedPageResult(feeds: [], nextCursor: nil, hasNext: false)
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        throw FeedDataSourceError.notFound
    }

    func toggleLike(feedId: Int) async throws {}

    func fetchLikers(feedId: Int) async throws -> [User] {
        []
    }
}
#endif
