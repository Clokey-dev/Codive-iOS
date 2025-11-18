//
//  SearchDataSource.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import Foundation

final class SearchDataSource {
    
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
}
