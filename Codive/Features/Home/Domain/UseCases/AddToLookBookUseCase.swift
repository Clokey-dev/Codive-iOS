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
    
    // 룩북 추가하기 바텀시트
    func execute() async throws -> [LookBookBottomSheetEntity] {
        return try await repository.fetchLookBookList()
    }
}
