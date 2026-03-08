//
//  StatisticsRepository.swift
//  Codive
//
//  Created by 황상환 on 2/26/26.
//

import Foundation

// MARK: - StatisticsRepository

protocol StatisticsRepository {
    func checkStatisticsCondition() async throws -> Bool
}
