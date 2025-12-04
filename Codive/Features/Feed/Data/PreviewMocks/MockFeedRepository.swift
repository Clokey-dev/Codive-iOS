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
        // 만약 외부에서 feed를 주입하지 않으면, 기본 더미 데이터를 생성합니다.
        if let feed = feed {
            self.resultFeed = feed
        } else {
            let dummyUser = User(id: "previewUser", nickname: "프리뷰 유저", profileImageUrl: nil)
            let dummyImageTags: [ImageClothTag] = [
                ImageClothTag(clothId: 101, locationX: 0.25, locationY: 0.3),
                ImageClothTag(clothId: 102, locationX: 0.75, locationY: 0.5),
                ImageClothTag(clothId: 103, locationX: 0.5, locationY: 0.75)
            ]
            let dummyFeedImage = FeedImage(imageUrl: "https://example.com/image.jpg", tags: dummyImageTags)
            
            self.resultFeed = Feed(
                id: 1,
                content: "이것은 프리뷰용 테스트 피드 내용입니다. 코디가 아주 멋지네요!",
                author: dummyUser,
                images: [dummyFeedImage],
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

    func fetchFeedDetail(id: Int) async throws -> Feed {
        return resultFeed
    }

    func toggleLike(feedId: Int) async throws {
        let newIsLiked = !(resultFeed.isLiked ?? false)
        let newLikeCount = newIsLiked ? (resultFeed.likeCount ?? 0) + 1 : (resultFeed.likeCount ?? 1) - 1
        
        resultFeed = Feed(
            id: resultFeed.id,
            content: resultFeed.content,
            author: resultFeed.author,
            images: resultFeed.images,
            situationId: resultFeed.situationId,
            styleIds: resultFeed.styleIds,
            hashtags: resultFeed.hashtags,
            createdAt: resultFeed.createdAt,
            likeCount: newLikeCount,
            isLiked: newIsLiked,
            commentCount: resultFeed.commentCount
        )
    }
}
#endif
