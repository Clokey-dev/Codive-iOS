//
//  MockFeedRepository.swift
//  Codive
//
//  Created by 황상환 on 2025/12/03.
//

#if DEBUG
import Foundation

/// 프리뷰 및 테스트에서 사용하기 위한 Mock FeedRepository
final class MockFeedRepository: FeedRepository {
    var resultFeed: Feed

    init(feed: Feed? = nil) {
        // 만약 외부에서 feed를 주입하지 않으면, 기본 더미 데이터를 생성
        if let feed = feed {
            self.resultFeed = feed
        } else {
            let dummyUser = User(id: "previewUser", nickname: "프리뷰 유저", profileImageUrl: nil)

            // 첫 번째 이미지 - 태그 3개
            let firstImageTags: [ImageClothTag] = [
                ImageClothTag(clothId: 101, locationX: 0.25, locationY: 0.3),
                ImageClothTag(clothId: 102, locationX: 0.75, locationY: 0.5),
                ImageClothTag(clothId: 103, locationX: 0.5, locationY: 0.75)
            ]
            let firstFeedImage = FeedImage(imageUrl: "https://via.placeholder.com/600x800", tags: firstImageTags)

            // 두 번째 이미지 - 태그 3개
            let secondImageTags: [ImageClothTag] = [
                ImageClothTag(clothId: 201, locationX: 0.3, locationY: 0.25),
                ImageClothTag(clothId: 202, locationX: 0.7, locationY: 0.6),
                ImageClothTag(clothId: 203, locationX: 0.5, locationY: 0.85)
            ]
            let secondFeedImage = FeedImage(imageUrl: "https://via.placeholder.com/600x800/0000FF", tags: secondImageTags)

            self.resultFeed = Feed(
                id: 1,
                content: "이것은 프리뷰용 테스트 피드 내용입니다. 코디가 아주 멋지네요!",
                author: dummyUser,
                images: [firstFeedImage, secondFeedImage],
                situationId: 1,
                styleIds: [1, 2],
                hashtags: ["#미리보기", "#OOTD"],
                createdAt: Date(),
                likeCount: 99,
                isLiked: true,
                commentCount: 9
            )
        }
    }

    func fetchFeeds(page: Int, limit: Int, styleIds: [Int]?, situationIds: [Int]?, followingOnly: Bool) async throws -> [Feed] {
        return []
    }

    func fetchFeedDetail(feedId: Int) async throws -> Feed {
        return resultFeed
    }

    func toggleLike(feedId: Int) async throws {
        print("Like toggled for feedId: \(feedId)")
    }
    
    func fetchLikers(feedId: Int) async throws -> [User] {
        print("Fetching likers for feedId: \(feedId)")
        return [
            .init(id: "1", nickname: "패셔니스타", profileImageUrl: nil),
            .init(id: "2", nickname: "코디장인", profileImageUrl: nil),
            .init(id: "3", nickname: "스타일헌터", profileImageUrl: nil),
            .init(id: "4", nickname: "옷잘알", profileImageUrl: nil)
        ]
    }
}
#endif
