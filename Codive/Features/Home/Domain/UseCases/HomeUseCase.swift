//
//  HomeUseCase.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import CoreLocation

final class HomeUseCase {
    private let repository: HomeRepository

    init(repository: HomeRepository) {
        self.repository = repository
    }

    /// 현재 위치 기반 날씨 정보를 가져오는 UseCase
    func execute(for location: CLLocation) async throws -> WeatherData {
        return try await repository.fetchWeatherData(for: location)
    }
}
