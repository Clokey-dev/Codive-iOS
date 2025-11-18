//
//  PhotoTagViewModel.swift
//  Codive
//
//  Created by 황상환 on 10/14/25.
//

import Foundation
import UIKit

// MARK: - PhotoTagViewModel
@MainActor
final class PhotoTagViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var currentPhoto: SelectedPhoto
    let allPhotos: [SelectedPhoto]
    
    private let navigationRouter: NavigationRouter
    
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
