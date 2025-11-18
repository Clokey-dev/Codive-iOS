//
//  PhotoTagViewModel.swift
//  Codive
//
//  Created by 황상환 on 10/14/25.
//

import Foundation
import UIKit
import Combine

// MARK: - PhotoTagViewModel
@MainActor
final class PhotoTagViewModel: ObservableObject {
    
    // MARK: - Properties
    
    static let photoTagsUpdated = PassthroughSubject<(photoId: String, tags: [ClothTag]), Never>()

    @Published var currentPhoto: SelectedPhoto
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "전체"
    @Published var selectedProducts: Set<UUID> = []
    @Published var clothTags: [ClothTag] = []

    let allPhotos: [SelectedPhoto]
    private let navigationRouter: NavigationRouter

    // Mock 데이터
    let mockClothItems: [ProductItem] = [
        ProductItem(imageName: "sample1", isTodayCloth: true, brand: "Nike", name: "에어포스 1"),
        ProductItem(imageName: "sample2", isTodayCloth: true, brand: "Adidas", name: "후디"),
        ProductItem(imageName: "sample3", isTodayCloth: true, brand: nil, name: "검은 모자"),
        ProductItem(imageName: "sample4", isTodayCloth: false, brand: "Uniqlo", name: "오버핏 티셔츠"),
        ProductItem(imageName: "sample5", isTodayCloth: false, brand: "Zara", name: "슬랙스"),
        ProductItem(imageName: "sample6", isTodayCloth: false, brand: nil, name: nil)
    ]
    
    // MARK: - Computed Properties
    var isCompleteEnabled: Bool {
        // TODO: 태그가 추가되었을 때만 활성화
        return true
    }
    
    // MARK: - Initializer
    init(
        photo: SelectedPhoto,
        allPhotos: [SelectedPhoto],
        navigationRouter: NavigationRouter
    ) {
        self.currentPhoto = photo
        self.allPhotos = allPhotos
        self.navigationRouter = navigationRouter
        
        // 기존 태그가 있으면 불러오기
        self.clothTags = photo.clothTags
        // 기존 태그의 clothId들을 selectedProducts에 추가
        self.selectedProducts = Set(photo.clothTags.map { $0.clothId })
    }
    
    // MARK: - Methods
    func completeTagging() {
        // 이벤트 발행
        Self.photoTagsUpdated.send((photoId: currentPhoto.id, tags: clothTags))
        // 이전 화면으로 돌아가기
        navigationRouter.navigateBack()
    }
    
    func dismissView() {
        navigationRouter.navigateBack()
    }
    
    func handleProductSelection(_ product: ProductItem) {
        if selectedProducts.contains(product.id) {
            // 선택 해제 - 태그 제거
            selectedProducts.remove(product.id)
            clothTags.removeAll { $0.clothId == product.id }
        } else {
            // 선택 - 태그 추가
            selectedProducts.insert(product.id)
            addClothTag(from: product)
        }
    }
    
    func addClothTag(from product: ProductItem) {
        let newTag = ClothTag(
            id: UUID(),
            clothId: product.id,
            brand: product.brand ?? "",
            name: product.name ?? "",
            locationX: 0.5, 
            locationY: 0.5
        )
        clothTags.append(newTag)
    }

    func removeClothTag(tagId: UUID) {
        if let tag = clothTags.first(where: { $0.id == tagId }) {
            selectedProducts.remove(tag.clothId)
            clothTags.removeAll { $0.id == tagId }
        }
    }

    func updateTagLocation(tagId: UUID, x: CGFloat, y: CGFloat) {
        if let index = clothTags.firstIndex(where: { $0.id == tagId }) {
            clothTags[index].locationX = x
            clothTags[index].locationY = y
        }
    }
}
