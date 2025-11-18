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
    lazy var clothDataSource = ClothDataSource()
    
    // MARK: - Repositories
    lazy var photoRepository: PhotoRepository = PhotoRepositoryImpl(
        dataSource: photoDataSource
    )
    
    lazy var clothRepository: ClothRepository = ClothRepositoryImpl(
        dataSource: clothDataSource
    )
    
    // MARK: - UseCases
    lazy var fetchPhotosUseCase = FetchPhotosUseCase(
        repository: photoRepository
    )
    
    lazy var processImageUseCase = ProcessImageUseCase()
    
    lazy var fetchClothItemsUseCase = FetchClothItemsUseCase(
        repository: clothRepository
    )
    
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
            navigationRouter: navigationRouter,
            fetchClothItemsUseCase: fetchClothItemsUseCase
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
        let viewModel = PhotoTagViewModel(
            photo: photo,
            allPhotos: allPhotos,
            navigationRouter: navigationRouter,
            fetchClothItemsUseCase: fetchClothItemsUseCase
        )
        return PhotoTagView(viewModel: viewModel)
    }
}
