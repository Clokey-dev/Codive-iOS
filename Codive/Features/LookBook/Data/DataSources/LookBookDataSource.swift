//
//  LookBookDataSource.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import Foundation

final class LookBookDataSource {
    
    // MARK: - Dummy LookBook List
    
    // 룩북 리스트 더미데이터(완)
    private var dummyLookBooks: [LookBookEntity] = [
        LookBookEntity(
            lookBookId: 1,
            lookbookName: "영화관 데이트 룩",
            imageUrl: "https://images.unsplash.com/photo-1520975916090-3105956dac38?w=600&q=80",
            count: 2
        ),
        LookBookEntity(
            lookBookId: 2,
            lookbookName: "편안한 데일리 코디",
            imageUrl: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&q=80",
            count: 1
        ),
        LookBookEntity(
            lookBookId: 3,
            lookbookName: "스트릿 캐주얼",
            imageUrl: "https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=600&q=80",
            count: 4
        ),
        LookBookEntity(
            lookBookId: 4,
            lookbookName: "파티/모임 코디",
            imageUrl: "https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?w=600&q=80",
            count: 3
        )
    ]
    
    // MARK: - Dummy Codis by LookBook

    // 룩북의 코디 리스트 더미데이터 (완)
    private var lookbookDetailCodi: [Int: [SpecificLookBookCodiEntity]] = [
        1: [ // 데이트 룩 (ID: 1)
            SpecificLookBookCodiEntity(
                coordinateId: 11,
                coordinateName: "로맨틱 시사회 룩",
                coordinateLiked: false,
                imageUrl: "https://image.msscdn.net/images/style/detail/37395/detail_37395_1_500.jpg",
                ),
            SpecificLookBookCodiEntity(
                coordinateId: 12,
                coordinateName: "따뜻한 카페 데이트",
                coordinateLiked: true,
                imageUrl: "https://image.msscdn.net/images/style/detail/37390/detail_37390_1_500.jpg")
           ],
        2: [ // 데일리 룩 (ID: 2)
            SpecificLookBookCodiEntity(
                coordinateId: 21,
                coordinateName: "캐주얼 오버핏",
                coordinateLiked: true,
                imageUrl: "https://image.msscdn.net/images/style/detail/37375/detail_37375_1_500.jpg",
                ),
            SpecificLookBookCodiEntity(
                coordinateId: 22,
                coordinateName: "편한 집앞 마실룩",
                coordinateLiked: false,
                imageUrl: "https://image.msscdn.net/images/style/detail/37370/detail_37370_1_500.jpg",
                )
           ]
    ]
    
    // MARK: - Dummy Before Codi List
    
    /// 이전 등록 코디 더미데이터 (완)
    private var dummyBeforeCoordinateDaily: [BeforeCoordinateDailyEntity] = [
        BeforeCoordinateDailyEntity(
            coordinateId: 1,
            imageUrl: "https://image.msscdn.net/images/style/detail/37395/detail_37395_1_500.jpg",
            date: "2025.08.09"),
        BeforeCoordinateDailyEntity(
            coordinateId: 2,
            imageUrl: "https://image.msscdn.net/images/style/detail/37390/detail_37390_1_500.jpg",
            date: "2025.08.01")
    ]
    
    // MARK: - Dummy Codi Detail
    
    /// 코디 상세 화면에서 사용하는 더미 데이터
    /// 코디 ID를 key로 하여 상세 정보(상의/하의/신발/메모/날짜)를 제공한다.
    private var codiDetails: [Int: CoordinatePreviewEntity] = [
        11: CoordinatePreviewEntity(
            coordinateId: 11,
            imageUrl: "https://image.msscdn.net/images/style/detail/37395/detail_37395_1_500.jpg",
//            topImageURL: "https://image.msscdn.net/images/goods_img/20230823/3505663/3505663_16927703370903_500.jpg",
//            bottomImageURL: "https://image.msscdn.net/images/goods_img/20230209/3067644/3067644_16759086395254_500.jpg",
//            shoeImageURL: "https://image.msscdn.net/images/goods_img/20221031/2902341/2902341_1_500.jpg",
            coordinateName: "로맨틱 시사회 룩",
            coordinateMemo: "1주년이니까 오빠가 사준 신발 신고가야됨"
        ),
        12: CoordinatePreviewEntity(
            coordinateId: 12,
            imageUrl: "https://image.msscdn.net/images/style/detail/37390/detail_37390_1_500.jpg",
//            topImageURL: "https://image.msscdn.net/images/goods_img/20240115/3792446/3792446_17053040307044_500.jpg",
//            bottomImageURL: "https://image.msscdn.net/images/goods_img/20230209/3067644/3067644_16759086395254_500.jpg",
//            shoeImageURL: "https://image.msscdn.net/images/goods_img/20221031/2902341/2902341_1_500.jpg",
            coordinateName: "따뜻한 카페 데이트",
            coordinateMemo: "겨울 카페 데이트 코디"
        )
    ]
    
    // MARK: - Dummy Product List
    
    /// 코디 구성 아이템 선택 화면에서 사용하는 상품 더미 데이터
    private var dummyProducts: [ProductItem] = [
        ProductItem(id: 1, imageName: "https://pngimg.com/uploads/jacket/jacket_PNG8055.png", isTodayCloth: true, brand: "아디다스", name: "트랙탑"),
        ProductItem(id: 2, imageName: "https://pngimg.com/uploads/hoodie/hoodie_PNG27.png", isTodayCloth: false, brand: "나이키", name: "후드티"),
        ProductItem(id: 3, imageName: "https://pngimg.com/uploads/jeans/jeans_PNG5777.png", isTodayCloth: false, brand: "리바이스", name: "데님 팬츠"),
        ProductItem(id: 4, imageName: "https://pngimg.com/uploads/jacket/jacket_PNG8066.png", isTodayCloth: false, brand: "노스페이스", name: "패딩"),
        ProductItem(id: 5, imageName: "https://pngimg.com/uploads/running_shoes/running_shoes_PNG5823.png", isTodayCloth: true, brand: "뉴발란스", name: "990v6"),
        ProductItem(id: 6, imageName: "https://pngimg.com/uploads/cap/cap_PNG5687.png", isTodayCloth: false, brand: "뉴에라", name: "볼캡")
    ]
    
    // MARK: - Fetch APIs
    
    /// LookBook 목록 조회(완)
    func fetchLookBookList() async throws -> [LookBookEntity] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return dummyLookBooks
    }
    
    /// 이전 코디 목록 조회(완)
    func fetchBeforeCoordinateDaily() async throws -> [BeforeCoordinateDailyEntity] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return dummyBeforeCoordinateDaily
    }
    
    /// 특정 LookBook에 속한 코디 목록 조회(완)
    func fetchCodisForLookBook(id lookbookId: Int) async throws -> [SpecificLookBookCodiEntity] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return lookbookDetailCodi[lookbookId] ?? []
    }
    
    /// 룩북 생성 (POST, 완)
    func createLookBook(title: String) async throws -> CreateLookBookEntity {
        try await Task.sleep(nanoseconds: 500_000_000)

        let newId = (dummyLookBooks.map { $0.lookBookId }.max() ?? 0) + 1

        let newLookBook = LookBookEntity(
            lookBookId: newId,
            lookbookName: title,
            imageUrl: "https://via.placeholder.com/160",
            count: 0
        )

        dummyLookBooks.append(newLookBook)

        print("서버에 룩북 생성 요청: \(title)")
        return CreateLookBookEntity(lookBookId: newId)
    }
    
    /// 룩북 삭제 (DELETE, 완)
    func deleteLookBooks(_ requests: [DeleteLookBookEntity]) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)

        let ids = requests.map { $0.lookBookId }

        print("서버에 삭제 요청: lookBookIds \(ids)")

        dummyLookBooks.removeAll { ids.contains($0.lookBookId) }

        print("삭제 후 남은 LookBook: \(dummyLookBooks.map { $0.lookBookId })")
    }
    
    /// 코디 좋아요 (PATCH, 완)
    func toggleCodiLike(_ request: CodiLikeEntity, isLiked: Bool) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)

        print("""
        서버에 좋아요 PATCH 요청
        - coordinateId: \(request.coordinateId)
        - isLiked: \(isLiked)
        """)
    }
    
    /// 코디 삭제(DELETE, 완)
    func deleteCodis(_ requests: [DeleteCodiEntity], lookbookId: Int) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)

        let ids = requests.map { $0.coordinateId }

        print("서버에 코디 삭제 요청: \(ids)")

        guard var codis = lookbookDetailCodi[lookbookId] else { return }

        codis.removeAll { ids.contains($0.coordinateId) }
        lookbookDetailCodi[lookbookId] = codis

        print("삭제 후 남은 코디:", codis.map { $0.coordinateId })
    }
    
    /// 룩북 이름 수정(PATCH, 완)
    func editLookBook(_ entity: EditLookBookEntity) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)

        print("""
        서버에 룩북 수정 PATCH 요청
        - lookBookId: \(entity.lookBookId)
        - name: \(entity.name)
        """)
        
        guard let index = dummyLookBooks.firstIndex(where: { $0.lookBookId == entity.lookBookId }) else {
            throw NSError(domain: "LookBookNotFound", code: 404)
        }
        dummyLookBooks[index].lookbookName = entity.name
    }
    
    /// 코디 preview 조회(GET, 완)
    func fetchCoordinatePreview(coordinateId: Int) async throws -> CoordinatePreviewEntity {
        try await Task.sleep(nanoseconds: 300_000_000)

        // 👉 실제 서버에서는 OpenAPI generated API 호출
        // let response = try await api.getCoordinatePreview(id: coordinateId)

        return CoordinatePreviewEntity(
            coordinateId: coordinateId,
            imageUrl: "https://image.msscdn.net/images/style/detail/37395/detail_37395_1_500.jpg",
            coordinateName: "로맨틱 시사회 룩",
            coordinateMemo: "1주년 기념 코디"
        )
    }
    
    /// 상품 목록 조회
    func fetchProductList() async throws -> [ProductItem] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return dummyProducts
    }
}
