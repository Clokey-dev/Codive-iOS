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
    @Published var selectedProducts: Set<Int> = []
    @Published var clothTags: [ClothTag] = []
    @Published var clothItems: [ProductItem] = []
    @Published var errorMessage: String?

    let allPhotos: [SelectedPhoto]
    private let navigationRouter: NavigationRouter
    private let fetchClothItemsUseCase: FetchClothItemsUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var isCompleteEnabled: Bool {
        return true
    }

    // MARK: - Initializer
    init(
        photo: SelectedPhoto,
        allPhotos: [SelectedPhoto],
        navigationRouter: NavigationRouter,
        fetchClothItemsUseCase: FetchClothItemsUseCase
    ) {
        self.currentPhoto = photo
        self.allPhotos = allPhotos
        self.navigationRouter = navigationRouter
        self.fetchClothItemsUseCase = fetchClothItemsUseCase

        // 기존 태그가 있으면 불러오기
        self.clothTags = photo.clothTags
        // 기존 태그의 clothId들을 selectedProducts에 추가
        self.selectedProducts = Set(photo.clothTags.map { $0.clothId })

        // 카테고리 변경 시 자동 재조회
        $selectedCategory
            .dropFirst()
            .sink { [weak self] _ in
                Task {
                    await self?.fetchClothItems()
                }
            }
            .store(in: &cancellables)

        // 옷 목록 가져오기
        Task {
            await fetchClothItems()
        }
    }
    
    // MARK: - Methods
    // TODO: 코디 완성 후 태그하기 진입 시, 해당 코디에 사용된 clothId 목록을 전달받아
    // isTodayCloth: true 설정 + 자동 선택 처리 필요 (백엔드 API 필드 추가 or 클라이언트 처리)
    func fetchClothItems() async {
        errorMessage = nil
        do {
            clothItems = try await fetchClothItemsUseCase.execute(category: selectedCategory)
        } catch {
            #if DEBUG
            print("[PhotoTag] Failed to fetch cloth items: \(error)")
            #endif
            clothItems = []
            errorMessage = "옷 목록을 불러오지 못했습니다"
        }
    }
    
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
            imageUrl: product.imageUrl,
            mainCategory: product.mainCategory,
            subCategory: product.subCategory,
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
