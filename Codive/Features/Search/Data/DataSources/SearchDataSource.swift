//
//  SearchDataSource.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import Foundation

final class SearchDataSource {
    
    func fetchRecentSearchTags() -> [SearchTagEntity] {
        return [
            SearchTagEntity(id: 1, text: "드뮤어룩"),
            SearchTagEntity(id: 2, text: "한강룩"),
            SearchTagEntity(id: 3, text: "여름 원피스"),
            SearchTagEntity(id: 4, text: "패션이 좋아요")
        ]
    }
    
    func fetchRecommendedNews() -> [NewsEntity] {
        return [
            NewsEntity(
                id: 1,
                imageUrl: "https://picsum.photos/273/300",
                title: "개강룩!\n첫 인상 잡수 올리기"
            ),
            NewsEntity(
                id: 2,
                imageUrl: "https://picsum.photos/273/301",
                title: "가을 자켓\n오늘의 코디"
            )
        ]
    }
    
    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private func getAllPosts() -> [PostEntity] {
        return [
            PostEntity(
                id: 1,
                postImageUrl: "https://picsum.photos/id/1018/162/216",
                profileImageUrl: "https://picsum.photos/id/237/28/28",
                nickname: "유저A",
                likes: 150,
                date: createDate(year: 2025, month: 11, day: 19),
                description: "가을 자켓 코디"
            ),
            PostEntity(
                id: 2,
                postImageUrl: "https://picsum.photos/id/1019/162/216",
                profileImageUrl: nil,
                nickname: "유저B",
                likes: 80,
                date: createDate(year: 2025, month: 11, day: 17),
                description: "겨울 드뮤어룩"
            ),
            PostEntity(
                id: 3,
                postImageUrl: "https://picsum.photos/id/1020/162/216",
                profileImageUrl: "https://picsum.photos/id/100/28/28",
                nickname: "유저C",
                likes: 250,
                date: createDate(year: 2025, month: 11, day: 18),
                description: "데일리룩 추천"
            ),
            PostEntity(
                id: 4,
                postImageUrl: "https://picsum.photos/id/1021/162/216",
                profileImageUrl: nil,
                nickname: "유저D",
                likes: 50,
                date: createDate(year: 2025, month: 11, day: 19),
                description: "드뮤어룩 첼시부츠"
            )
        ]
    }
    
    func fetchPosts(query: String) -> [PostEntity] {
        let allPosts = getAllPosts()
        
        if query.isEmpty || query == "전체" {
            return allPosts
        }
        
        let lowercasedQuery = query.lowercased()

        return allPosts.filter { post in
            let matchNickname = post.nickname.lowercased().contains(lowercasedQuery)
            let matchDescription = post.description?.lowercased().contains(lowercasedQuery) ?? false
            return matchNickname || matchDescription
        }
    }
}
