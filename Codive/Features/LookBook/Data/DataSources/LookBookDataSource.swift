//
//  LookBookDataSource.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import Foundation

final class LookBookDataSource {
    private let dummyLookBooks: [LookBookEntity] = [
        LookBookEntity(id: "1", imageURL: "https://via.placeholder.com/160/F08080/FFFFFF?text=Date+Look+1", cardTitle: "영화관 데이트 룩"),
        LookBookEntity(id: "2", imageURL: "https://via.placeholder.com/160/ADD8E6/000000?text=Daily+Look+2", cardTitle: "편안한 데일리 코디"),
        LookBookEntity(id: "3", imageURL: "https://via.placeholder.com/160/90EE90/000000?text=Basic+Look+3", cardTitle: "봄 스타일링 추천"),
        LookBookEntity(id: "4", imageURL: "https://via.placeholder.com/160/FFD700/000000?text=Party+Look+4", cardTitle: "파티/모임 코디"),
        LookBookEntity(id: "5", imageURL: "https://via.placeholder.com/160/E6E6FA/000000?text=Office+Look+5", cardTitle: "오피스 캐주얼"),
        LookBookEntity(id: "6", imageURL: "https://via.placeholder.com/160/A9A9A9/FFFFFF?text=Workout+Look+6", cardTitle: "운동/액티브웨어")
    ]
    
    func fetchLookBookList() async throws -> [LookBookEntity] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return dummyLookBooks
    }
}
