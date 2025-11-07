//
//  HomeRepositoryImpl.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import CoreLocation

final class HomeRepositoryImpl: HomeRepository {
    private let dataSource: HomeDatasource
    
    init(dataSource: HomeDatasource) {
        self.dataSource = dataSource
    }

    func fetchWeatherData(for location: CLLocation) async throws -> WeatherData {
        return try await dataSource.fetchWeatherData(for: location)
    }
}
