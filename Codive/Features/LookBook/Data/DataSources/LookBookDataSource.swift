//
//  LookBookDataSource.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import Foundation
import CodiveAPI

protocol LookBookDataSourceProtocol {
    /// 룩북 전체 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> LookBookListResponseDTO
    
    /// 개별 룩북 내 코디 조회
    func fetchLookBookCoordinateList(
        lookBookId: Int64,
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getCoordinates.Input.Query.directionPayload
    ) async throws -> LookBookCoordinateResponseDTO
    
    /// 과거 일일 코디 조회
    func fetchPastCoordinates(
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.Coordinate_getDailyCoordinates.Input.Query.directionPayload
    ) async throws -> PastDailyCoordinateResponseDTO
    
    /// 코디 preview 조회
    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewResponseDTO
    
    /// 코디 detail 조회
    func fetchCoordinateDetail(
        coordinateId: Int64
    ) async throws -> [CoordinateDetailResponseDTO]
    
    /// 오늘의 코디 옷 정보 조회
    func fetchTodayCoordinateClothes() async throws -> [GetTodayCoordinateClothResponseDTO]
    
    /// 옷 리스트 조회
    func fetchClothItems(category: String?) async throws -> [ProductItem]
    
    /// 룩북 생성
    func createLookBook(request: CreateLookBookAPIRequestDTO) async throws -> CreateLookBookResponseDTO
    
    /// 코디 수동 생성
    func createManualCoordinate(request: CreateManualCoordinateAPIRequestDTO) async throws -> CreateManualCoordinateAPIResponseDTO
    
    /// 룩북 삭제
    func deleteLookBook(lookBookId: Int64) async throws
    
    /// 룩북 수정
    func updateLookBook(lookBookId: Int64, request: UpdateLookBookAPIRequestDTO) async throws
    
    /// 코디 삭제
    func deleteCoordinate(coordinateId: Int64) async throws
    
    /// 코디 좋아요 토글
    func patchCoordinateLike(coordinateId: Int64) async throws
    
    /// 코디 수정
    func patchUpdateCoordinates(coordinateId: Int64, request: EditCoordinateRequestDTO) async throws
    
    /// 이전 일일 코디로 자동 생성
    func createAutoDailyCoordinate(request: CreateAutoDailyCoordinateAPIRequestDTO) async throws -> CreateAutoDailyCoordinateAPIResponseDTO
}

final class LookBookDataSource: LookBookDataSourceProtocol {
    private let apiService: LookBookAPIServiceProtocol
    
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
            coordinateName: "로맨틱 시사회 룩",
            coordinateMemo: "1주년이니까 오빠가 사준 신발 신고가야됨"
        ),
        12: CoordinatePreviewEntity(
            coordinateId: 12,
            imageUrl: "https://image.msscdn.net/images/style/detail/37390/detail_37390_1_500.jpg",
            coordinateName: "따뜻한 카페 데이트",
            coordinateMemo: "겨울 카페 데이트 코디"
        )
    ]
    
    // MARK: - Dummy Product List
    
//    /// 코디 구성 아이템 선택 화면에서 사용하는 상품 더미 데이터
//    private var dummyProducts: [ProductItem] = [
//        ProductItem(id: 1, imageName: "https://pngimg.com/uploads/jacket/jacket_PNG8055.png", isTodayCloth: true, brand: "아디다스", name: "트랙탑"),
//        ProductItem(id: 2, imageName: "https://pngimg.com/uploads/hoodie/hoodie_PNG27.png", isTodayCloth: false, brand: "나이키", name: "후드티"),
//        ProductItem(id: 3, imageName: "https://pngimg.com/uploads/jeans/jeans_PNG5777.png", isTodayCloth: false, brand: "리바이스", name: "데님 팬츠"),
//        ProductItem(id: 4, imageName: "https://pngimg.com/uploads/jacket/jacket_PNG8066.png", isTodayCloth: false, brand: "노스페이스", name: "패딩"),
//        ProductItem(id: 5, imageName: "https://pngimg.com/uploads/running_shoes/running_shoes_PNG5823.png", isTodayCloth: true, brand: "뉴발란스", name: "990v6"),
//        ProductItem(id: 6, imageName: "https://pngimg.com/uploads/cap/cap_PNG5687.png", isTodayCloth: false, brand: "뉴에라", name: "볼캡")
//    ]
    
    // MARK: - Initializer
    init(
        apiService: LookBookAPIServiceProtocol = LookBookAPIService()
    ) {
        self.apiService = apiService
    }
    
    /// 룩북 전체 리스트 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> LookBookListResponseDTO {
        return try await apiService.fetchLookBookList(
            lastLookBookId: lastLookBookId,
            size: size,
            direction: direction
        )
    }
    
    /// 개별 룩북 전체 리스트 조회
    func fetchLookBookCoordinateList(
        lookBookId: Int64,
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getCoordinates.Input.Query.directionPayload
    ) async throws -> LookBookCoordinateResponseDTO {
        return try await apiService.fetchLookBookCoordinateList(
            lookBookId: lookBookId,
            lastCoordinateId: lastCoordinateId,
            size: size,
            direction: direction
        )
        // 🔥 MOCK DATA (서버 연동 전)
//        return LookBookCoordinateResponseDTO(
//            content: [
//                LookBookCoordinateListResponseItem(
//                    coordinateId: 1,
//                    coordinateName: "로맨틱 시사회 룩",
//                    coordinateLiked: true,
//                    imageUrl: "https://image.msscdn.net/images/style/detail/37395/detail_37395_1_500.jpg"
//                ),
//                LookBookCoordinateListResponseItem(
//                    coordinateId: 2,
//                    coordinateName: "따뜻한 카페 데이트",
//                    coordinateLiked: false,
//                    imageUrl: "https://image.msscdn.net/images/style/detail/37390/detail_37390_1_500.jpg"
//                ),
//                LookBookCoordinateListResponseItem(
//                    coordinateId: 13,
//                    coordinateName: "캐주얼 출근 룩",
//                    coordinateLiked: false,
//                    imageUrl: "https://image.msscdn.net/images/style/detail/37410/detail_37410_1_500.jpg"
//                )
//            ],
//            isLast: true
//            )
    }
    
    /// 과거 일일 코디 조회
    func fetchPastCoordinates(
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.Coordinate_getDailyCoordinates.Input.Query.directionPayload
    ) async throws -> PastDailyCoordinateResponseDTO {
        return try await apiService.fetchPastCoordinates(
            lastCoordinateId: lastCoordinateId,
            size: size,
            direction: direction
        )
    }
    
    /// 코디 preview 조회
    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewResponseDTO {
        return try await apiService.fetchCoordinatePreview(coordinateId: coordinateId)
    }
    
    /// 코디 detail 조회
    func fetchCoordinateDetail(
        coordinateId: Int64
    ) async throws -> [CoordinateDetailResponseDTO] {
        return try await apiService.fetchCoordinateDetail(coordinateId: coordinateId)
    }
    
//    func fetchCoordinateDetail(
//        coordinateId: Int64
//    ) async throws -> [CoordinateDetailResponseDTO] {
//
//        // 🔥 서버 없을 때
//        return [
//            CoordinateDetailResponseDTO(
//                coordinateClothId: 1,
//                locationX: 0.3,
//                locationY: 0.4,
//                ratio: 1.0,
//                degree: 0,
//                order: 0,
//                imageUrl: "https://pngimg.com/uploads/jacket/jacket_PNG8055.png",
//                brand: "아디다스",
//                name: "트랙탑",
//                category: "TOP",
//                parentCategory: "OUTER"
//            ),
//            CoordinateDetailResponseDTO(
//                coordinateClothId: 2,
//                locationX: 0.5,
//                locationY: 0.7,
//                ratio: 1.0,
//                degree: 0,
//                order: 1,
//                imageUrl: "https://pngimg.com/uploads/jeans/jeans_PNG5777.png",
//                brand: "리바이스",
//                name: "데님 팬츠",
//                category: "BOTTOM",
//                parentCategory: "PANTS"
//            )
//        ]
//    }
    
    /// 오늘의 코디 옷 정보 조회
    func fetchTodayCoordinateClothes() async throws -> [GetTodayCoordinateClothResponseDTO] {
        return try await apiService.fetchTodayCoordinateClothes()
    }
    
    /// 옷 리스트 조회
    func fetchClothItems(category: String?) async throws -> [ProductItem] {
        // 전체 옷 목록 조회 (페이지네이션 없이 전체)
        let result = try await apiService.fetchClothes(
            lastClothId: nil,
            size: 100,
            categoryId: nil,
            seasons: []
        )
        
        return result.clothes.map { item in
            ProductItem(
                id: Int(item.clothId),
                imageUrl: item.imageUrl,
                brand: item.brand,
                name: item.name
            )
        }
    }
    
    /// 룩북 생성
    func createLookBook(
        request: CreateLookBookAPIRequestDTO
    ) async throws -> CreateLookBookResponseDTO {
        return try await apiService.createLookBook(request: request)
    }
    
    /// 코디 수동 생성
    func createManualCoordinate(request: CreateManualCoordinateAPIRequestDTO) async throws -> CreateManualCoordinateAPIResponseDTO {
        return try await apiService.createManualCoordinate(request: request)
    }
    
    /// 룩북 삭제
    func deleteLookBook(lookBookId: Int64) async throws {
        try await apiService.deleteLookBook(lookBookId: lookBookId)
    }
    
    /// 룩북 수정
    func updateLookBook(lookBookId: Int64, request: UpdateLookBookAPIRequestDTO) async throws {
        try await apiService.updateLookBook(lookBookId: lookBookId, request: request)
    }
    
    /// 코디 삭제
    func deleteCoordinate(coordinateId: Int64) async throws {
        try await apiService.deleteCoordinate(coordinateId: coordinateId)
    }
    
    /// 코디 좋아요 토글
    func patchCoordinateLike(coordinateId: Int64) async throws {
        try await apiService.patchCoordinateLike(coordinateId: coordinateId)
    }
    
    /// 코디 수정
    func patchUpdateCoordinates(coordinateId: Int64, request: EditCoordinateRequestDTO) async throws {
        try await apiService.patchUpdateCoordinates(coordinateId: coordinateId, request: request)
    }
    
    /// 이전 일일 코디로 자동 생성
    func createAutoDailyCoordinate(request: CreateAutoDailyCoordinateAPIRequestDTO) async throws -> CreateAutoDailyCoordinateAPIResponseDTO {
        return try await apiService.createAutoDailyCoordinate(request: request)
    }
}

extension LookBookDataSource {
    
    // MARK: - Example Fetch APIs
    
    /// 이전 코디 목록 조회(완)
    func fetchBeforeCoordinateDaily() async throws -> [BeforeCoordinateDailyEntity] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return dummyBeforeCoordinateDaily
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

//        guard var codis = lookbookDetailCodi[lookbookId] else { return }
//
//        codis.removeAll { ids.contains(Int($0.coordinateId)) }
//        lookbookDetailCodi[lookbookId] = codis

        print("삭제 후 남은 코디:"/*, codis.map { $0.coordinateId }*/)
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
}
