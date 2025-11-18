//
//  PhotoTagViewModel.swift
//  Codive
//
//  Created by 황상환 on 10/14/25.
//

import Foundation
import UIKit

// MARK: - ClothTag Model
struct ClothTag: Identifiable {
    let id: UUID
    let clothId: UUID
    let brand: String
    let name: String
    var locationX: CGFloat
    var locationY: CGFloat
}

// MARK: - PhotoTagViewModel
@MainActor
final class PhotoTagViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var currentPhoto: SelectedPhoto
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "전체"
    @Published var selectedProducts: Set<UUID> = []
    @Published var clothTags: [ClothTag] = []

    let allPhotos: [SelectedPhoto]
    private let navigationRouter: NavigationRouter

    // Mock 데이터
    let mockClothItems: [ProductItem] = [
        ProductItem(imageName: "sample1", isTodayCloth: true),
        ProductItem(imageName: "sample2", isTodayCloth: true),
        ProductItem(imageName: "sample3", isTodayCloth: true),
        ProductItem(imageName: "sample4", isTodayCloth: false),
        ProductItem(imageName: "sample5", isTodayCloth: false),
        ProductItem(imageName: "sample6", isTodayCloth: false)
    ]
    
    // MARK: - Computed Properties
    var isCompleteEnabled: Bool {
        // TODO: 태그가 추가되었을 때만 활성화
        return true
    }
    
    // MARK: - Initializer
    init(photo: SelectedPhoto, allPhotos: [SelectedPhoto], navigationRouter: NavigationRouter) {
        self.currentPhoto = photo
        self.allPhotos = allPhotos
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - Methods
    func completeTagging() {
        // 이전 화면(RecordDetailView)으로 돌아가기
        navigationRouter.navigateBack()
    }
    
    func dismissView() {
        navigationRouter.navigateBack()
    }
}
