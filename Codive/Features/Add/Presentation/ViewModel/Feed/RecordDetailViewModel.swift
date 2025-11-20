//
//  RecordDetailViewModel.swift
//  Codive
//
//  Created by 황상환 on 10/14/25.
//

import Foundation
import UIKit
import SwiftUI
import Combine

// MARK: - RecordDetailViewModel
@MainActor
final class RecordDetailViewModel: ObservableObject {
    
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    
    @Published var selectedPhotos: [SelectedPhoto]
    @Published var currentPhotoIndex: Int = 0
    
    // MultiSelect Properties
    @Published var selectedStyles: Set<String> = []
    @Published var selectedSituations: Set<String> = []
    
    // TextField Property
    @Published var captionText: String = ""

    // Alert Property
    @Published var showExitAlert: Bool = false

    private let navigationRouter: NavigationRouter
    
    // MARK: - Options
    let styleOptions = [
        TextLiteral.Add.styleCasual,
        TextLiteral.Add.styleLoving,
        TextLiteral.Add.styleMinimal,
        TextLiteral.Add.styleVintage,
        TextLiteral.Add.styleSporty,
        TextLiteral.Add.styleStreet,
        TextLiteral.Add.styleChic,
        TextLiteral.Add.styleOffice,
        TextLiteral.Add.styleClassic,
        TextLiteral.Add.styleHighteen
    ]
    let situationOptions = [
        TextLiteral.Add.situationDate,
        TextLiteral.Add.situationDaily,
        TextLiteral.Add.situationTravel,
        TextLiteral.Add.situationExercise,
        TextLiteral.Add.situationFestival,
        TextLiteral.Add.situationWork,
        TextLiteral.Add.situationParty
    ]
    
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
        
        // 태그 업데이트 구독
        setupPhotoTagSubscription()
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
        showExitAlert = true
    }

    func confirmExit() {
        navigationRouter.navigateBack()
    }

    private func setupPhotoTagSubscription() {
        PhotoTagViewModel.photoTagsUpdated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photoId, tags in
                guard let self = self else { return }
                // 현재 selectedPhotos에 포함된 사진만 업데이트
                guard self.selectedPhotos.contains(where: { $0.id == photoId }) else { return }
                self.updatePhotoTags(for: photoId, tags: tags)
            }
            .store(in: &cancellables)
    }
    
    private func updatePhotoTags(for photoId: String, tags: [ClothTag]) {
        if let index = selectedPhotos.firstIndex(where: { $0.id == photoId }) {
            selectedPhotos[index].clothTags = tags
        }
    }
    
    func navigateToPhotoTag() {
        guard let currentPhoto = currentPhoto else { return }
        navigationRouter.navigate(to: .photoTag(photo: currentPhoto, allPhotos: selectedPhotos))
    }
}
