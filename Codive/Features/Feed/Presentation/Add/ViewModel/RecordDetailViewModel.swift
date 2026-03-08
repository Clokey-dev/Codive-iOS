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
import Kingfisher

// MARK: - RecordDetailViewModel
@MainActor
final class RecordDetailViewModel: ObservableObject {

    // MARK: - Constants

    private enum Constants {
        static let minStyleCount = 1
        static let maxStyleCount = 3
    }

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

    // Edit Mode
    @Published var isEditMode: Bool = false
    private var editingFeedId: Int?
    private var editingFeedData: Feed?

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
        // 스타일 최소 1개, 최대 3개 선택 필수, 상황 최소 1개 선택 필수
        return selectedStyles.count >= Constants.minStyleCount &&
               selectedStyles.count <= Constants.maxStyleCount &&
               !selectedSituations.isEmpty
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
        self.isEditMode = false

        // 태그 업데이트 구독
        setupPhotoTagSubscription()
    }

    /// 수정 모드 Initializer
    init(
        feed: Feed,
        navigationRouter: NavigationRouter,
        recordDataSource: RecordDataSource = DefaultRecordDataSource()
    ) {
        self.navigationRouter = navigationRouter
        self.recordDataSource = recordDataSource
        self.isEditMode = true
        self.editingFeedId = feed.id
        self.editingFeedData = feed

        // 이미지 데이터 로드
        self.selectedPhotos = []

        // 상태 초기화
        self.selectedStyles = Set(feed.styleNames ?? [])
        self.captionText = feed.content ?? ""

        // 상황 설정 (첫 번째만)
        if let situationId = feed.situationId {
            if let situationItem = SituationConstants.find(byId: Int64(situationId)) {
                self.selectedSituations.insert(situationItem.name)
            }
        }

        // 이미지 로드
        Task {
            await self.loadImagesFromFeed(feed)
        }

        // 태그 업데이트 구독
        setupPhotoTagSubscription()
    }
    
    // MARK: - Methods
    func updateCurrentPhotoIndex(_ index: Int) {
        currentPhotoIndex = index
    }

    /// Feed의 이미지들을 SelectedPhoto로 변환하여 로드
    private func loadImagesFromFeed(_ feed: Feed) async {
        var loadedPhotos: [SelectedPhoto] = []

        for (index, feedImage) in feed.images.enumerated() {
            if let image = await downloadImage(from: feedImage.imageUrl) {
                var selectedPhoto = SelectedPhoto(
                    id: UUID().uuidString,
                    croppedImage: image,
                    order: index,
                    clothTags: [] // 기존 태그는 나중에 로드됨
                )
                selectedPhoto.imageUrl = feedImage.imageUrl // 기존 이미지 URL 저장
                loadedPhotos.append(selectedPhoto)
            }
        }

        DispatchQueue.main.async {
            self.selectedPhotos = loadedPhotos
        }
    }

    /// URL에서 이미지를 다운로드
    private func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }

        return await withCheckedContinuation { continuation in
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let imageResult):
                    continuation.resume(returning: imageResult.image)
                case .failure:
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func completeRecord() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let request = try buildRecordRequest()
                try await saveRecord(request)
                isLoading = false
                NotificationCenter.default.post(name: .feedDidCreate, object: nil)
                let message = isEditMode ? "기록이 수정되었습니다" : "기록이 저장되었습니다"
                navigationRouter.showSuccessAndNavigate(message: message, to: .feed)
            } catch {
                handleRecordError(error)
            }
        }
    }

    // MARK: - Private Helper Methods

    private func buildRecordRequest() throws -> RecordCreateRequest {
        // 1. 스타일 ID 변환
        let styleIds = StyleConstants.getIds(from: selectedStyles)
        guard !styleIds.isEmpty else {
            throw RecordError.noStyleSelected
        }

        // 2. 상황 ID 변환
        guard let situationId = SituationConstants.getFirstId(from: selectedSituations) else {
            throw RecordError.noSituationSelected
        }

        // 3. 해시태그 추출
        let hashtags = extractHashtags(from: captionText)

        // 4. 사진 데이터 변환
        let photos = selectedPhotos.map { photo in
            var recordPhoto = RecordPhoto(
                image: photo.croppedImage,
                clothTags: photo.clothTags.map { tag in
                    RecordClothTag(
                        clothId: Int64(tag.clothId),
                        locationX: Double(tag.locationX),
                        locationY: Double(tag.locationY)
                    )
                }
            )
            recordPhoto.imageUrl = photo.imageUrl
            return recordPhoto
        }

        // 5. 요청 생성
        return RecordCreateRequest(
            content: captionText.isEmpty ? nil : captionText,
            situationId: situationId,
            styleIds: styleIds,
            hashtags: hashtags,
            photos: photos
        )
    }

    private func saveRecord(_ request: RecordCreateRequest) async throws {
        if isEditMode, let feedId = editingFeedId {
            // API는 Int64를 요구하므로 변환
            let historyId = Int64(feedId)
            try await recordDataSource.updateRecord(historyId: historyId, request: request)
        } else {
            _ = try await recordDataSource.createRecord(request: request)
        }
    }

    private func handleRecordError(_ error: Error) {
        isLoading = false
        errorMessage = error.localizedDescription
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
            return TextLiteral.Add.noStyleSelected
        case .noSituationSelected:
            return TextLiteral.Add.noSituationSelected
        }
    }
}
