//
//  PreviewEmptyClothRepo.swift
//  Codive
//
//  Created by 황상환 on 5/6/26.
//

#if DEBUG
import CodiveAPI
import Foundation

/// 리포트 관련 SwiftUI 프리뷰에서 ViewModel 의존성 주입용 빈 ClothRepository.
/// 모든 메서드가 빈 응답을 반환하므로 옷 조회 호출이 일어나도 뷰가 깨지지 않음.
final class PreviewEmptyClothRepo: ClothRepository {
    func fetchClothItems(category: String?) async throws -> [ProductItem] { [] }
    func saveClothes(_ inputs: [ClothInput], images: [Data]) async throws -> [Cloth] { [] }
    func fetchMyClosetClothItems(
        mainCategory: String?,
        subCategory: String?,
        seasons: Set<Season>,
        searchText: String?
    ) async throws -> [Cloth] { [] }
    func fetchClothList(
        lastClothId: Int?,
        size: Int,
        categoryId: Int?,
        seasons: Set<Season>
    ) async throws -> (clothes: [Cloth], isLast: Bool) { ([], true) }
    func fetchClothDetail(clothId: Int) async throws -> ClothDetailResult {
        ClothDetailResult(
            clothImageUrl: "",
            parentCategory: nil,
            category: nil,
            name: nil,
            brand: nil,
            clothUrl: nil,
            seasons: []
        )
    }
    func updateCloth(clothId: Int, request: ClothUpdateAPIRequest) async throws {}
    func deleteCloth(clothId: Int) async throws {}
    func deleteClothItems(_ clothIds: [Int]) async throws {}
    func fetchLookBookList(
        lastLookBookId: Int64?,
        size: Int32,
        direction: Operations.LookBook_getLookBooks.Input.Query.directionPayload
    ) async throws -> (content: [LookBookEntity], isLast: Bool) { ([], true) }
}
#endif
