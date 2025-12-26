//
//  AddToLookBookUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/27/25.
//

final class AddToLookBookUseCase {

    private let repository: HomeRepository

    init(repository: HomeRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [LookBookBottomSheetEntity] {
        return try await repository.fetchLookBookList()
    }
}
