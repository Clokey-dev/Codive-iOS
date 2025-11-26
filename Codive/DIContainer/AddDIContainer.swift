//
//  AddDIContainer.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Foundation

@MainActor
final class AddDIContainer {
    
    // MARK: - Properties
    private let feedDIContainer: FeedDIContainer
    private let closetDIContainer: ClosetDIContainer
    private let sharedDIContainer: SharedDIContainer
    
    let navigationRouter: NavigationRouter
    lazy var addViewFactory = AddViewFactory(addDIContainer: self)
    
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
    
    func makePhotoTagViewModel(photo: SelectedPhoto, allPhotos: [SelectedPhoto]) -> PhotoTagViewModel {
        return PhotoTagViewModel(
            photo: photo,
            allPhotos: allPhotos,
            navigationRouter: navigationRouter,
            fetchClothItemsUseCase: closetDIContainer.makeFetchClothItemsUseCase()
        )
    }
    
    func makePhotoEditViewModel(selectedPhotos: [SelectedPhoto], flowType: PhotoEditFlowType = .record) -> PhotoEditViewModel {
        return PhotoEditViewModel(
            selectedPhotos: selectedPhotos,
            navigationRouter: navigationRouter,
            flowType: flowType
        )
    }

    func makeClothAddViewModel(selectedPhotos: [SelectedPhoto]) -> ClothAddViewModel {
        return ClothAddViewModel(
            selectedPhotos: selectedPhotos,
            navigationRouter: navigationRouter
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
    
    func makePhotoTagView(photo: SelectedPhoto, allPhotos: [SelectedPhoto]) -> PhotoTagView {
        let viewModel = makePhotoTagViewModel(photo: photo, allPhotos: allPhotos)
        return PhotoTagView(viewModel: viewModel)
    }
    
    func makePhotoEditView(selectedPhotos: [SelectedPhoto], flowType: PhotoEditFlowType = .record) -> PhotoEditView {
        return PhotoEditView(
            viewModel: makePhotoEditViewModel(selectedPhotos: selectedPhotos, flowType: flowType)
        )
    }

    func makeClothAddView(selectedPhotos: [SelectedPhoto]) -> ClothAddView {
        return ClothAddView(
            viewModel: makeClothAddViewModel(selectedPhotos: selectedPhotos)
        )
    }
}
