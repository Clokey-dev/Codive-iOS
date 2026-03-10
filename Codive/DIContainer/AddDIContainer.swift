//
//  AddDIContainer.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Foundation
import UIKit

@MainActor
final class AddDIContainer {
    
    // MARK: - Properties
    private let feedDIContainer: FeedDIContainer
    private let closetDIContainer: ClosetDIContainer
    private let sharedDIContainer: SharedDIContainer
    
    let navigationRouter: NavigationRouter
    lazy var addViewFactory = AddViewFactory(addDIContainer: self)

    // 지우개 편집 시 공유 참조
    weak var activeClothAddViewModel: ClothAddViewModel?
    var pendingErasedImage: UIImage?
    
    // MARK: - Initializer
    init(
        navigationRouter: NavigationRouter,
        feedDIContainer: FeedDIContainer,
        closetDIContainer: ClosetDIContainer,
        sharedDIContainer: SharedDIContainer
    ) {
        self.navigationRouter = navigationRouter
        self.feedDIContainer = feedDIContainer
        self.closetDIContainer = closetDIContainer
        self.sharedDIContainer = sharedDIContainer
    }
    
    // MARK: - ViewModels
    func makeRecordAddViewModel(flowType: PhotoEditFlowType = .record) -> RecordAddViewModel {
        return RecordAddViewModel(
            fetchPhotosUseCase: sharedDIContainer.makeFetchPhotosUseCase(),
            processImageUseCase: sharedDIContainer.makeProcessImageUseCase(),
            navigationRouter: navigationRouter,
            flowType: flowType
        )
    }
    
    func makeRecordDetailViewModel(selectedPhotos: [SelectedPhoto]) -> RecordDetailViewModel {
        return RecordDetailViewModel(
            selectedPhotos: selectedPhotos,
            navigationRouter: navigationRouter
        )
    }

    func makeRecordDetailViewModelForEdit(feed: Feed) -> RecordDetailViewModel {
        return RecordDetailViewModel(
            feed: feed,
            navigationRouter: navigationRouter
        )
    }
    
    func makePhotoTagViewModel(photo: SelectedPhoto, allPhotos: [SelectedPhoto]) -> PhotoTagViewModel {
        return PhotoTagViewModel(
            photo: photo,
            allPhotos: allPhotos,
            navigationRouter: navigationRouter,
            fetchClothItemsUseCase: closetDIContainer.makeFetchClothItemsUseCase()
        )
    }
    
    func makePhotoEditViewModel(selectedPhotos: [SelectedPhoto], flowType: PhotoEditFlowType = .record, isAIEnabled: Bool = false) -> PhotoEditViewModel {
        return PhotoEditViewModel(
            selectedPhotos: selectedPhotos,
            navigationRouter: navigationRouter,
            flowType: flowType,
            isAIEnabled: isAIEnabled
        )
    }

    func makeClothAddViewModel(selectedPhotos: [SelectedPhoto], isAIEnabled: Bool = false) -> ClothAddViewModel {
        return ClothAddViewModel(
            selectedPhotos: selectedPhotos,
            navigationRouter: navigationRouter,
            addClothUseCase: closetDIContainer.makeAddClothUseCase(),
            clothAIUseCase: closetDIContainer.makeClothAIUseCase(),
            isAIEnabled: isAIEnabled
        )
    }
    
    // MARK: - Views
    func makeRecordAddView(flowType: PhotoEditFlowType = .record) -> RecordAddView {
        return RecordAddView(viewModel: makeRecordAddViewModel(flowType: flowType))
    }
    
    func makeRecordDetailView(selectedPhotos: [SelectedPhoto]) -> RecordDetailView {
        return RecordDetailView(
            viewModel: makeRecordDetailViewModel(selectedPhotos: selectedPhotos)
        )
    }

    func makeRecordDetailViewForEdit(feed: Feed) -> RecordDetailView {
        return RecordDetailView(
            viewModel: makeRecordDetailViewModelForEdit(feed: feed)
        )
    }
    
    func makePhotoTagView(photo: SelectedPhoto, allPhotos: [SelectedPhoto]) -> PhotoTagView {
        let viewModel = makePhotoTagViewModel(photo: photo, allPhotos: allPhotos)
        return PhotoTagView(viewModel: viewModel)
    }
    
    func makePhotoEditView(selectedPhotos: [SelectedPhoto], flowType: PhotoEditFlowType = .record, isAIEnabled: Bool = false) -> PhotoEditView {
        return PhotoEditView(
            viewModel: makePhotoEditViewModel(selectedPhotos: selectedPhotos, flowType: flowType, isAIEnabled: isAIEnabled)
        )
    }

    func makeClothAddView(selectedPhotos: [SelectedPhoto], isAIEnabled: Bool = false) -> ClothAddView {
        let viewModel = makeClothAddViewModel(selectedPhotos: selectedPhotos, isAIEnabled: isAIEnabled)
        // NavigationStack이 재호출해도 @StateObject가 유지하는 최초 viewModel을 덮어쓰지 않음
        if activeClothAddViewModel == nil {
            activeClothAddViewModel = viewModel
        }
        return ClothAddView(viewModel: viewModel)
    }

    func makeEraserEditorView(photo: SelectedPhoto, photoIndex: Int) -> EraserEditorView? {
        guard let viewModel = activeClothAddViewModel else { return nil }
        return EraserEditorView(
            originalImage: photo.croppedImage,
            photoIndex: photoIndex,
            navigationRouter: navigationRouter,
            clothAddViewModel: viewModel
        ) { [weak self] image in
            self?.pendingErasedImage = image
        }
    }

    func makeEraserPreviewView(photoIndex: Int) -> EraserPreviewView? {
        guard let viewModel = activeClothAddViewModel,
              let image = pendingErasedImage else { return nil }
        return EraserPreviewView(
            previewImage: image,
            photoIndex: photoIndex,
            navigationRouter: navigationRouter,
            clothAddViewModel: viewModel
        )
    }
}
