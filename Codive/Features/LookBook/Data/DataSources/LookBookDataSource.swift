// LookBookDataSource.swift
//
//  LookBookDataSource.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import Foundation

final class LookBookDataSource {

    private var dummyLookBooks: [LookBookEntity] = [
        LookBookEntity(id: 1, imageURL: "https://via.placeholder.com/160/F08080/FFFFFF?text=Date+Look+1", cardTitle: "영화관 데이트 룩"),
        LookBookEntity(id: 2, imageURL: "https://via.placeholder.com/160/ADD8E6/000000?text=Daily+Look+2", cardTitle: "편안한 데일리 코디"),
        LookBookEntity(id: 3, imageURL: "https://via.placeholder.com/160/90EE90/000000?text=Basic+Look+3", cardTitle: "봄 스타일링 추천"),
        LookBookEntity(id: 4, imageURL: "https://via.placeholder.com/160/FFD700/000000?text=Party+Look+4", cardTitle: "파티/모임 코디"),
        LookBookEntity(id: 5, imageURL: "https://via.placeholder.com/160/E6E6FA/000000?text=Office+Look+5", cardTitle: "오피스 캐주얼"),
        LookBookEntity(id: 6, imageURL: "https://via.placeholder.com/160/A9A9A9/FFFFFF?text=Workout+Look+6", cardTitle: "운동/액티브웨어")
    ]
    
    private var lookbookCodis: [Int: [LookBookEntity]] = [
        1: [ // 데이트 룩 (ID: 1) 코디 목록
            LookBookEntity(id: 11, imageURL: "https://via.placeholder.com/160/F08080/FFFFFF?text=Date+Codi+11", cardTitle: "로맨틱 시사회 룩"),
            LookBookEntity(id: 12, imageURL: "https://via.placeholder.com/160/F08080/FFFFFF?text=Date+Codi+12", cardTitle: "따뜻한 카페 데이트"),
            LookBookEntity(id: 13, imageURL: "https://via.placeholder.com/160/F08080/FFFFFF?text=Date+Codi+13", cardTitle: "활동적인 피크닉 룩"),
            LookBookEntity(id: 14, imageURL: "https://via.placeholder.com/160/F08080/FFFFFF?text=Date+Codi+14", cardTitle: "뮤지컬 관람 코디")
           ],
        2: [ // 데일리 룩 (ID: 2) 코디 목록
            LookBookEntity(id: 21, imageURL: "https://via.placeholder.com/160/ADD8E6/000000?text=Daily+Codi+21", cardTitle: "캐주얼 오버핏"),
            LookBookEntity(id: 22, imageURL: "https://via.placeholder.com/160/ADD8E6/000000?text=Daily+Codi+22", cardTitle: "편한 집앞 마실룩")
           ]
        // ... 필요한 경우 더미 데이터 추가
    ]
    
    func fetchLookBookList() async throws -> [LookBookEntity] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return dummyLookBooks
    }
    
    func deleteLookBooks(ids: [Int]) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        print("서버에 삭제 요청: lookbookId \(ids)")
        
        dummyLookBooks.removeAll { ids.contains($0.id) }
        print("삭제 후 남은 LookBook: \(dummyLookBooks.map { $0.id })")
    }

    func fetchCodisForLookBook(id lookbookId: Int) async throws -> [LookBookEntity] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return lookbookCodis[lookbookId] ?? []
    }
    
    func toggleLike(codyId: Int, isLiked: Bool) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        print("서버에 좋아요 상태 전송: Codi ID \(codyId), isLiked: \(isLiked)")
    }
}
