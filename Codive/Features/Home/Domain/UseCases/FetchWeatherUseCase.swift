//
//  FetchWeatherUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/25/25.
//

import CoreLocation

final class FetchWeatherUseCase {

    private let repository: HomeRepository

    init(repository: HomeRepository) {
        self.repository = repository
    }

    func execute(for location: CLLocation?) async throws -> WeatherData {
        return try await repository.fetchWeatherData(for: location)
    }
    
    func postTodayTemp(request: PostTodayTemperatureAPIRequestDTO) async throws {
        try await repository.postTodayTemp(request: request)
    }
}
