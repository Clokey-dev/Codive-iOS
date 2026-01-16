//
//  CodiUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/23/25.
//

final class CodiUseCase {

    // MARK: - Dependency
    private let repository: LookBookRepository

    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }
    
    /// 코디 프리뷰 조회
    func fetchCoordinatePreview(coordinateId: Int) async throws -> CoordinatePreviewEntity {
        try await repository.fetchCoordinatePreview(coordinateId: coordinateId)
    }
}
