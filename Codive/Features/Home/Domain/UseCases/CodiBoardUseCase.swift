//
//  CodiBoardUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/25/25.
//

final class CodiBoardUseCase {

    private let repository: HomeRepository

    init(repository: HomeRepository) {
        self.repository = repository
    }

    func loadCodiBoardImages() -> [DraggableImageEntity] {
        return repository.fetchInitialImages()
    }

    func saveCodiItems(_ images: [DraggableImageEntity]) {
        repository.saveCodiItems(images)
    }
}
