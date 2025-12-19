//
//  LookBookDataSource.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import Foundation

final class LookBookDataSource {

    private var dummyLookBooks: [LookBookEntity] = [
        LookBookEntity(id: 1, imageURL: "https://image.msscdn.net/images/goods_img/20230823/3505663/3505663_16927703370903_500.jpg", cardTitle: "영화관 데이트 룩"),
        LookBookEntity(id: 2, imageURL: "https://image.msscdn.net/images/goods_img/20240115/3792446/3792446_17053040307044_500.jpg", cardTitle: "편안한 데일리 코디"),
        LookBookEntity(id: 3, imageURL: "https://image.msscdn.net/images/goods_img/20230209/3067644/3067644_16759086395254_500.jpg", cardTitle: "봄 스타일링 추천"),
        LookBookEntity(id: 4, imageURL: "https://image.msscdn.net/images/goods_img/20230912/3553250/3553250_16945037307524_500.jpg", cardTitle: "파티/모임 코디"),
        LookBookEntity(id: 5, imageURL: "https://image.msscdn.net/images/goods_img/20221031/2902341/2902341_1_500.jpg", cardTitle: "오피스 캐주얼"),
        LookBookEntity(id: 6, imageURL: "https://image.msscdn.net/images/goods_img/20230302/3119129/3119129_16777353986884_500.jpg", cardTitle: "운동/액티브웨어")
    ]

    private var lookbookCodis: [Int: [LookBookEntity]] = [
        1: [ // 데이트 룩 (ID: 1) 코디 목록
            LookBookEntity(id: 11, imageURL: "https://image.msscdn.net/images/style/detail/37395/detail_37395_1_500.jpg", cardTitle: "로맨틱 시사회 룩"),
            LookBookEntity(id: 12, imageURL: "https://image.msscdn.net/images/style/detail/37390/detail_37390_1_500.jpg", cardTitle: "따뜻한 카페 데이트"),
            LookBookEntity(id: 13, imageURL: "https://image.msscdn.net/images/style/detail/37385/detail_37385_1_500.jpg", cardTitle: "활동적인 피크닉 룩"),
            LookBookEntity(id: 14, imageURL: "https://image.msscdn.net/images/style/detail/37380/detail_37380_1_500.jpg", cardTitle: "뮤지컬 관람 코디")
        ],
        2: [ // 데일리 룩 (ID: 2) 코디 목록
            LookBookEntity(id: 21, imageURL: "https://image.msscdn.net/images/style/detail/37375/detail_37375_1_500.jpg", cardTitle: "캐주얼 오버핏"),
            LookBookEntity(id: 22, imageURL: "https://image.msscdn.net/images/style/detail/37370/detail_37370_1_500.jpg", cardTitle: "편한 집앞 마실룩")
        ]
    ]
    
    // 코디 상세 정보 더미 데이터
    private var codiDetails: [Int: CodiDetailEntity] = [
        11: CodiDetailEntity(
            id: 11,
            imageURL: "https://image.msscdn.net/images/style/detail/37395/detail_37395_1_500.jpg",
            topImageURL: "https://image.msscdn.net/images/goods_img/20230823/3505663/3505663_16927703370903_500.jpg",
            bottomImageURL: "https://image.msscdn.net/images/goods_img/20230209/3067644/3067644_16759086395254_500.jpg",
            shoeImageURL: "https://image.msscdn.net/images/goods_img/20221031/2902341/2902341_1_500.jpg",
            name: "로맨틱 시사회 룩",
            memo: "1주년이니까 오빠가 사준 신발 신고가야됨",
            date: "2025.08.09"
        ),
        12: CodiDetailEntity(
            id: 12,
            imageURL: "https://image.msscdn.net/images/style/detail/37390/detail_37390_1_500.jpg",
            topImageURL: "https://image.msscdn.net/images/goods_img/20240115/3792446/3792446_17053040307044_500.jpg",
            bottomImageURL: "https://image.msscdn.net/images/goods_img/20230209/3067644/3067644_16759086395254_500.jpg",
            shoeImageURL: "https://image.msscdn.net/images/goods_img/20221031/2902341/2902341_1_500.jpg",
            name: "따뜻한 카페 데이트",
            memo: "겨울 카페 데이트 코디",
            date: "2025.08.01"
        ),
        13: CodiDetailEntity(
            id: 13,
            imageURL: "https://image.msscdn.net/images/style/detail/37385/detail_37385_1_500.jpg",
            topImageURL: "https://image.msscdn.net/images/goods_img/20230823/3505663/3505663_16927703370903_500.jpg",
            bottomImageURL: "https://image.msscdn.net/images/goods_img/20230912/3553250/3553250_16945037307524_500.jpg",
            shoeImageURL: "https://image.msscdn.net/images/goods_img/20221031/2902341/2902341_1_500.jpg",
            name: "활동적인 피크닉 룩",
            memo: "야외 활동하기 좋은 스타일",
            date: "2025.08.11"
        ),
        14: CodiDetailEntity(
            id: 14,
            imageURL: "https://image.msscdn.net/images/style/detail/37380/detail_37380_1_500.jpg",
            topImageURL: "https://image.msscdn.net/images/goods_img/20240115/3792446/3792446_17053040307044_500.jpg",
            bottomImageURL: "https://image.msscdn.net/images/goods_img/20230912/3553250/3553250_16945037307524_500.jpg",
            shoeImageURL: "https://image.msscdn.net/images/goods_img/20221031/2902341/2902341_1_500.jpg",
            name: "뮤지컬 관람 코디",
            memo: "공연장에 입고 가기 좋은 코디",
            date: "2025.08.14"
        )
    ]
    
    // 수정된 상품 더미 데이터
    private var dummyProducts: [ProductItem] = [
        ProductItem(
            id: 1,
            imageName: "https://pngimg.com/uploads/jacket/jacket_PNG8055.png",
            isTodayCloth: true,
            brand: "아디다스",
            name: "트랙탑"
        ),
        ProductItem(
            id: 2,
            imageName: "https://pngimg.com/uploads/hoodie/hoodie_PNG27.png",
            isTodayCloth: false,
            brand: "나이키",
            name: "후드티"
        ),
        ProductItem(
            id: 3,
            imageName: "https://pngimg.com/uploads/jeans/jeans_PNG5777.png",
            isTodayCloth: false,
            brand: "리바이스",
            name: "데님 팬츠"
        ),
        ProductItem(
            id: 4,
            imageName: "https://pngimg.com/uploads/jacket/jacket_PNG8066.png",
            isTodayCloth: false,
            brand: "노스페이스",
            name: "패딩"
        ),
        ProductItem(
            id: 5,
            imageName: "https://pngimg.com/uploads/running_shoes/running_shoes_PNG5823.png",
            isTodayCloth: true,
            brand: "뉴발란스",
            name: "990v6"
        ),
        ProductItem(
            id: 6,
            imageName: "https://pngimg.com/uploads/cap/cap_PNG5687.png",
            isTodayCloth: false,
            brand: "뉴에라",
            name: "볼캡"
        )
    ]
    
    private var dummyBeforeCodi: [BeforeCodiEntity] = [
        BeforeCodiEntity(id: 1, imageURL: "https://image.msscdn.net/images/style/detail/37395/detail_37395_1_500.jpg", date: "2025.08.09", name: "로맨틱 시사회 룩", memo: "영화관 데이트하기 좋은 스타일"),
        BeforeCodiEntity(id: 2, imageURL: "https://image.msscdn.net/images/style/detail/37390/detail_37390_1_500.jpg", date: "2025.08.01", name: "따뜻한 카페 데이트", memo: "겨울 카페 데이트 코디"),
        BeforeCodiEntity(id: 3, imageURL: "https://image.msscdn.net/images/style/detail/37370/detail_37370_1_500.jpg", date: "2025.08.03", name: "편한 집앞 마실룩", memo: "동네 산책하기 좋은 편한 옷"),
        BeforeCodiEntity(id: 4, imageURL: "https://image.msscdn.net/images/style/detail/37370/detail_37370_1_500.jpg", date: "2025.08.08", name: "캐주얼 데일리", memo: "평소에 입기 좋은 무난한 코디"),
        BeforeCodiEntity(id: 5, imageURL: "https://image.msscdn.net/images/style/detail/37385/detail_37385_1_500.jpg", date: "2025.08.11", name: "활동적인 피크닉 룩", memo: "야외 활동하기 좋은 스타일"),
        BeforeCodiEntity(id: 6, imageURL: "https://image.msscdn.net/images/style/detail/37380/detail_37380_1_500.jpg", date: "2025.08.14", name: "뮤지컬 관람 코디", memo: "공연장에 입고 가기 좋은 코디")
    ]
    
    func fetchLookBookList() async throws -> [LookBookEntity] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return dummyLookBooks
    }
    
    func fetchBeforeCodiList() async throws -> [BeforeCodiEntity] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return dummyBeforeCodi
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
    
    func fetchCodiDetail(codiId: Int) async throws -> CodiDetailEntity? {
        try await Task.sleep(nanoseconds: 300_000_000)
        return codiDetails[codiId]
    }
    
    func toggleLike(codyId: Int, isLiked: Bool) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        print("서버에 좋아요 상태 전송: Codi ID \(codyId), isLiked: \(isLiked)")
    }
    
    func fetchProductList() async throws -> [ProductItem] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return dummyProducts
    }
}
