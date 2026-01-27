//
//  LookBookRepositoryImpl.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import CodiveAPI

final class LookBookRepositoryImpl: LookBookRepository {
    // MARK: - Properties
    private let datasource: LookBookDataSource
    
    // MARK: - Initializer
    init(datasource: LookBookDataSource) {
        self.datasource = datasource
    }
    
    // 룩북 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> (content: [LookBookEntity], isLast: Bool) {
        let dto = try await datasource.fetchLookBookList(
            lastLookBookId: lastLookBookId,
            size: size,
            direction: direction
        )
        
        return (
            content: dto.content.map { $0.toEntity() },
            isLast: dto.isLast
        )
    }
    
    // 특정 룩북의 코디 목록 조회
    func fetchLookBookCoordinateList(
        lookBookId: Int64,
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getCoordinates.Input.Query.directionPayload
    ) async throws -> (content: [SpecificLookBookCodiEntity], isLast: Bool) {
        let dto = try await datasource.fetchLookBookCoordinateList(
            lookBookId: lookBookId,
            lastCoordinateId: lastCoordinateId,
            size: size,
            direction: direction
        )
        
        return (
            content: dto.content.map { $0.toEntity() },
            isLast: dto.isLast
        )
    }
    
    /// 과거 일일 코디 조회
    func fetchPastCoordinates(
        lastCoordinateId: Int64?,
        size: Int32,
        direction: Operations.Coordinate_getDailyCoordinates.Input.Query.directionPayload
    ) async throws -> (content: [BeforeCoordinateDailyEntity], isLast: Bool) {
        let dto = try await datasource.fetchPastCoordinates(
            lastCoordinateId: lastCoordinateId,
            size: size,
            direction: direction
        )
        return (
            content: dto.content.map { $0.toEntity() },
            isLast: dto.isLast
        )
    }
    
    /// 코디 preview 조회
    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewEntity {
        let dto = try await datasource.fetchCoordinatePreview(coordinateId: coordinateId)
        return dto.toEntity()
    }
    
    /// 코디 detail 조회
    func fetchCoordinateDetail(
        coordinateId: Int64
    ) async throws -> [CoordinateDetailEntity] {

        let dtoList = try await datasource.fetchCoordinateDetail(
            coordinateId: coordinateId
        )

        return dtoList.map { $0.toEntity() }
    }
    
    /// 오늘의 코디 옷 정보 조회
    func fetchTodayCoordinateClothes() async throws -> [TodayCoordinateClothEntity] {
        let dtoList = try await datasource.fetchTodayCoordinateClothes()
        return dtoList.map { $0.toEntity() }
    }
    
    /// 룩북 생성
    func createLookBook(request: CreateLookBookAPIRequestDTO) async throws -> CreateLookBookResponseDTO {
        return try await datasource.createLookBook(request: request)
    }
    
    /// 코디 수동 생성
    func createManualCoordinate(
        request: CreateManualCoordinateAPIRequestDTO
    ) async throws -> ManualCoordinateEntity {

        let dto = try await datasource.createManualCoordinate(request: request)
        return dto.toEntity()
    }
    
    /// 룩북 삭제
    func deleteLookBook(lookBookId: Int64) async throws {
        try await datasource.deleteLookBook(lookBookId: lookBookId)
    }
    
    /// 룩북 수정
    func updateLookBook(lookBookId: Int64, request: UpdateLookBookAPIRequestDTO) async throws {
        try await datasource.updateLookBook(lookBookId: lookBookId, request: request)
    }
    
    /// 코디 삭제
    func deleteCoordinate(coordinateId: Int64) async throws {
        try await datasource.deleteCoordinate(coordinateId: coordinateId)
    }
    
    /// 코디 좋아요 토글
    func patchCoordinateLike(coordinateId: Int64) async throws {
        try await datasource.patchCoordinateLike(coordinateId: coordinateId)
    }
    
    /// 코디 수정
    func patchUpdateCoordinates(coordinateId: Int64, request: EditCoordinateRequestDTO) async throws {
        try await datasource.patchUpdateCoordinates(coordinateId: coordinateId, request: request)
    }
    
    /// 이전 일일 코디로 자동 생성
    func createAutoDailyCoordinate(
        request: CreateAutoDailyCoordinateAPIRequestDTO
    ) async throws -> AutoDailyCoordinateEntity {
        let dto = try await datasource.createAutoDailyCoordinate(request: request)
        return dto.toEntity()
    }
}

extension LookBookRepositoryImpl {
    func fetchBeforeCoordinateDaily() async throws -> [BeforeCoordinateDailyEntity] {
        return try await datasource.fetchBeforeCoordinateDaily()
    }
    
    func toggleCodiLike(_ request: CodiLikeEntity, isLiked: Bool) async throws {
        try await datasource.toggleCodiLike(request, isLiked: isLiked)
    }
    
    func deleteCodis(_ codis: [DeleteCodiEntity], lookbookId: Int) async throws {
        try await datasource.deleteCodis(codis, lookbookId: lookbookId)
    }
    
    func fetchCoordinatePreview(coordinateId: Int) async throws -> CoordinatePreviewEntity {
        try await datasource.fetchCoordinatePreview(coordinateId: coordinateId)
    }
    
    // MARK: - Product
    
    /// 코디 구성에 사용되는 상품 목록 조회
    func fetchProductList() async throws -> [ProductItem] {
        return try await datasource.fetchProductList()
    }
}
