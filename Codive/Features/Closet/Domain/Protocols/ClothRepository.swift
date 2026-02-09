//
//  ClothRepository.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation
import CodiveAPI

// MARK: - ClothRepository
protocol ClothRepository {
    func fetchClothItems(category: String?) async throws -> [ProductItem]
    func saveClothes(_ inputs: [ClothInput], images: [Data]) async throws -> [Cloth]

    // MyCloset 전용 메서드
    func fetchMyClosetClothItems(
        mainCategory: String?,
        subCategory: String?,
        seasons: Set<Season>,
        searchText: String?
    ) async throws -> [Cloth]
    
    /// 옷 목록 조회 (API 연동)
    func fetchClothList(
        lastClothId: Int?,
        size: Int,
        categoryId: Int?,
        seasons: Set<Season>
    ) async throws -> (clothes: [Cloth], isLast: Bool)
    
    /// 옷 상세 조회 (API 연동)
    func fetchClothDetail(clothId: Int) async throws -> ClothDetailResult
    
    /// 옷 수정 (API 연동)
    func updateCloth(clothId: Int, request: ClothUpdateAPIRequest) async throws
    
    /// 옷 삭제 (API 연동) - 단일
    func deleteCloth(clothId: Int) async throws

    func deleteClothItems(_ clothIds: [Int]) async throws
    
    /// 룩북 조회
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> (content: [LookBookEntity], isLast: Bool)
}
