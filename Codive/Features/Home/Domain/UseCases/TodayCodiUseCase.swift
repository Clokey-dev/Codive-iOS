//
//  TodayCodiUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/25/25.
//

final class TodayCodiUseCase {

    private let repository: HomeRepository

    init(repository: HomeRepository) {
        self.repository = repository
    }

    func loadTodaysCodi() -> [CodiItemEntity] {
        return repository.fetchCodiItems()
    }
    
    func recordTodayCodi(_ codi: TodayDailyCodi) async throws {
            try await repository.createTodayDailyCodi(codi)
        }
}
