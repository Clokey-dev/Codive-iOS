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
    
    /// 오늘의 코디 생성
    func createTodayCoordinate(
        request: CreateTodayCoordinateRequestDTO
    ) async throws -> TodayCoordinateEntity {
        try await repository.createTodayCoordinate(request: request)
    }
    
    /// 오늘의 코디 옷 정보 조회
    func fetchTodayCoordinateClothes() async throws -> [TodayCoordinateClothEntity] {
        try await repository.fetchTodayCoordinateClothes()
    }
}

extension TodayCodiUseCase {
    func loadTodaysCodi() -> [CodiItemEntity] {
        return repository.fetchCodiItems()
    }
    
    func recordTodayCodi(_ codi: TodayDailyCodi) async throws {
        try await repository.createTodayDailyCodi(codi)
    }
}
