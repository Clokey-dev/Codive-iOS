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
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - ViewModels
    func makeRecordAddViewModel() -> RecordAddViewModel {
        return RecordAddViewModel(
            fetchPhotosUseCase: fetchPhotosUseCase,
            navigationRouter: navigationRouter
        )
    }
    
    // MARK: - Views
    func makeRecordAddView() -> RecordAddView {
        return RecordAddView(viewModel: makeRecordAddViewModel())
    }
}
