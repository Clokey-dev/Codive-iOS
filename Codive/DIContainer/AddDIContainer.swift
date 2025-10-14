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
    let navigationRouter: NavigationRouter
    lazy var addViewFactory = AddViewFactory(addDIContainer: self)
    
    // MARK: - DataSources
    lazy var photoDataSource = PhotoDataSource()
    
    // MARK: - Repositories
    lazy var photoRepository: PhotoRepository = PhotoRepositoryImpl(
        dataSource: photoDataSource
    )
    
    // MARK: - UseCases
    lazy var fetchPhotosUseCase = FetchPhotosUseCase(
        repository: photoRepository
    )
    
    lazy var processImageUseCase = ProcessImageUseCase()
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - ViewModels
    func makeRecordAddViewModel() -> RecordAddViewModel {
        return RecordAddViewModel(
            fetchPhotosUseCase: fetchPhotosUseCase,
            processImageUseCase: processImageUseCase,
            navigationRouter: navigationRouter
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
            navigationRouter: navigationRouter
        )
    }
    
    // MARK: - Views
    func makeRecordAddView() -> RecordAddView {
        return RecordAddView(viewModel: makeRecordAddViewModel())
    }
    
    func makeRecordDetailView(selectedPhotos: [SelectedPhoto]) -> RecordDetailView {
        return RecordDetailView(
            viewModel: makeRecordDetailViewModel(selectedPhotos: selectedPhotos)
        )
    }
    
    func makePhotoTagView(photo: SelectedPhoto, allPhotos: [SelectedPhoto]) -> PhotoTagView {
        return PhotoTagView(
            viewModel: makePhotoTagViewModel(photo: photo, allPhotos: allPhotos)
        )
    }
}
