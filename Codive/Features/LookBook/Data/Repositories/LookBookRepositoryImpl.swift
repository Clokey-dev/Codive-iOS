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
    
    func createLookBook(request: CreateLookBookAPIRequestDTO) async throws -> CreateLookBookResponseDTO {
        return try await datasource.createLookBook(request: request)
    }

    func fetchBeforeCoordinateDaily() async throws -> [BeforeCoordinateDailyEntity] {
        return try await datasource.fetchBeforeCoordinateDaily()
    }
    
    func deleteLookBook(lookBookId: Int64) async throws {
        try await datasource.deleteLookBook(lookBookId: lookBookId)
    }

    func toggleCodiLike(_ request: CodiLikeEntity, isLiked: Bool) async throws {
        try await datasource.toggleCodiLike(request, isLiked: isLiked)
    }
    
    func deleteCodis(_ codis: [DeleteCodiEntity], lookbookId: Int) async throws {
        try await datasource.deleteCodis(codis, lookbookId: lookbookId)
    }

    func updateLookBook(lookBookId: Int64, request: UpdateLookBookAPIRequestDTO) async throws {
        try await datasource.updateLookBook(lookBookId: lookBookId, request: request)
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
