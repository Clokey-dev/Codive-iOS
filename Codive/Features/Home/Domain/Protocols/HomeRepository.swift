//
//  HomeRepository.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import CoreLocation

protocol HomeRepository {
    func fetchWeatherData(for location: CLLocation) async throws -> WeatherData
}
