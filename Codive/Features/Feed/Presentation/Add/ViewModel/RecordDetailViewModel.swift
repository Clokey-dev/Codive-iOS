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

    // Loading & Error State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let navigationRouter: NavigationRouter
    private let recordDataSource: RecordDataSource
    
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
    init(
        selectedPhotos: [SelectedPhoto],
        navigationRouter: NavigationRouter,
        recordDataSource: RecordDataSource = DefaultRecordDataSource()
    ) {
        self.selectedPhotos = selectedPhotos
        self.navigationRouter = navigationRouter
        self.recordDataSource = recordDataSource

        // 태그 업데이트 구독
        setupPhotoTagSubscription()
    }
    
    // MARK: - Methods
    func updateCurrentPhotoIndex(_ index: Int) {
        currentPhotoIndex = index
    }
    
    func completeRecord() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                // 1. 스타일 ID 변환
                let styleIds = StyleConstants.getIds(from: selectedStyles)
                guard !styleIds.isEmpty else {
                    throw RecordError.noStyleSelected
                }

                // 2. 상황 ID 변환 (첫 번째 선택)
                guard let situationId = SituationConstants.getFirstId(from: selectedSituations) else {
                    throw RecordError.noSituationSelected
                }

                // 3. 해시태그 추출
                let hashtags = extractHashtags(from: captionText)

                // 4. 사진 데이터 변환
                let photos = selectedPhotos.map { photo in
                    RecordPhoto(
                        image: photo.croppedImage,
                        clothTags: photo.clothTags.map { tag in
                            RecordClothTag(
                                clothId: Int64(tag.clothId),
                                locationX: Double(tag.locationX),
                                locationY: Double(tag.locationY)
                            )
                        }
                    )
                }

                // 5. 요청 생성
                let request = RecordCreateRequest(
                    content: captionText.isEmpty ? nil : captionText,
                    situationId: situationId,
                    styleIds: styleIds,
                    hashtags: hashtags,
                    photos: photos
                )

                // 6. API 호출
                _ = try await recordDataSource.createRecord(request: request)

                // 7. 성공 시 메인으로
                isLoading = false
                navigationRouter.navigateToRoot()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Helper Methods

    private func extractHashtags(from text: String) -> [String] {
        let pattern = "#[가-힣a-zA-Z0-9_]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }

        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)

        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            return String(text[range])
        }
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

// MARK: - Record Error

enum RecordError: LocalizedError {
    case noStyleSelected
    case noSituationSelected

    var errorDescription: String? {
        switch self {
        case .noStyleSelected:
            return "스타일을 선택해주세요."
        case .noSituationSelected:
            return "상황을 선택해주세요."
        }
    }
}
