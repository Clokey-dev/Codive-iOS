//
//  ClothDataSource.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import Foundation

// MARK: - ClothDataSource Protocol
protocol ClothDataSource {
    func fetchClothItems(category: String?) async throws -> [ProductItem]
    func uploadClothes(_ dtos: [ClothRequestDTO]) async throws -> [ClothResponseDTO]
}

// MARK: - DefaultClothDataSource
final class DefaultClothDataSource: ClothDataSource {

    // MARK: - Mock Data
    private let mockClothItems: [ProductItem] = [
        ProductItem(id: 1, imageName: "sample1", isTodayCloth: true, brand: "Nike", name: "에어포스 1"),
        ProductItem(id: 2, imageName: "sample2", isTodayCloth: true, brand: "Adidas", name: "후디"),
        ProductItem(id: 3, imageName: "sample3", isTodayCloth: true, brand: nil, name: "검은 모자"),
        ProductItem(id: 4, imageName: "sample4", isTodayCloth: false, brand: "Uniqlo", name: "오버핏 티셔츠"),
        ProductItem(id: 5, imageName: "sample5", isTodayCloth: false, brand: "Zara", name: "슬랙스"),
        ProductItem(id: 6, imageName: "sample6", isTodayCloth: false, brand: nil, name: nil)
    ]

    // MARK: - Methods
    func fetchClothItems(category: String?) async throws -> [ProductItem] {
        // TODO: 실제 API 호출로 대체

        // 카테고리 필터링 (전체면 전부 반환)
        if let category = category, category != "전체" {
            return mockClothItems.filter { _ in
                // TODO: ProductItem에 category 필드 추가 후 필터링
                return true
            }
        }

        return mockClothItems
    }

    func uploadClothes(_ dtos: [ClothRequestDTO]) async throws -> [ClothResponseDTO] {
        // TODO: 서버 API 호출 구현
        fatalError("Server API not implemented yet")
    }
}
