//
//  RecordDetailViewModel.swift
//  Codive
//
//  Created by 황상환 on 10/14/25.
//

import Foundation
import UIKit

// MARK: - RecordDetailViewModel
@MainActor
final class RecordDetailViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var selectedPhotos: [SelectedPhoto]
    @Published var currentPhotoIndex: Int = 0
    
    // MultiSelect Properties
    @Published var selectedStyles: Set<String> = []
    @Published var selectedSituations: Set<String> = []
    
    // TextField Property
    @Published var captionText: String = ""
    
    private let navigationRouter: NavigationRouter
    
    // MARK: - Options
    let styleOptions = ["캐주얼", "러블리", "미니멀", "빈티지", "스포티", "스트릿", "시크", "오피스룩", "캐주얼", "클래식", "하이틴"]
    let situationOptions = ["데이트", "데일리", "여행", "운동", "축제", "출근복", "파티"]
    
    // MARK: - Computed Properties
    var currentPhoto: SelectedPhoto? {
        guard selectedPhotos.indices.contains(currentPhotoIndex) else { return nil }
        return selectedPhotos[currentPhotoIndex]
    }
    
    var isCompleteEnabled: Bool {
        // 스타일 최소 1개, 최대 3개 선택 필수
        return selectedStyles.count >= 1 && selectedStyles.count <= 3
    }
    
    // MARK: - Initializer
    init(selectedPhotos: [SelectedPhoto], navigationRouter: NavigationRouter) {
        self.selectedPhotos = selectedPhotos
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - Methods
    func updateCurrentPhotoIndex(_ index: Int) {
        currentPhotoIndex = index
    }
    
    func completeRecord() {
        // TODO: 기록 저장 로직
        print("기록 완료")
        print("선택된 스타일: \(selectedStyles)")
        print("선택된 상황: \(selectedSituations)")
        print("캡션: \(captionText)")
        
        // 메인으로 돌아가기
        navigationRouter.navigateToRoot()
    }
    
    func dismissView() {
        navigationRouter.navigateBack()
    }
}
