//
//  StatisticsRepository.swift
//  Codive
//
//  Created by claude on 2/26/26.
//

import Foundation

// MARK: - StatisticsRepository

protocol StatisticsRepository {
    func checkStatisticsCondition() async throws -> Bool
}
