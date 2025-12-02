//
//  SharedDIContainer.swift
//  Codive
//
//  Created by gemini on 2025/11/22.
//

import Foundation

final class SharedDIContainer {
    
    // MARK: - DataSources
    private lazy var photoDataSource: PhotoDataSource = {
        return PhotoDataSource()
    }()
    
    // MARK: - Repositories
    private lazy var photoRepository: PhotoRepository = {
        return PhotoRepositoryImpl(dataSource: photoDataSource)
    }()
    
    // MARK: - UseCases
    func makeFetchPhotosUseCase() -> FetchPhotosUseCase {
        return FetchPhotosUseCase(repository: photoRepository)
    }
    
    func makeProcessImageUseCase() -> ProcessImageUseCase {
        return ProcessImageUseCase()
    }
}
