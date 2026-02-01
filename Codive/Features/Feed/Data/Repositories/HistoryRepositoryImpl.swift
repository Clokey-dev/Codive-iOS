//
//  HistoryRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 1/31/26.
//

import Foundation

final class HistoryRepositoryImpl: HistoryRepository {
    private let historyAPIService: HistoryAPIServiceProtocol

    init(historyAPIService: HistoryAPIServiceProtocol = HistoryAPIService()) {
        self.historyAPIService = historyAPIService
    }

    func fetchMonthlyHistory(memberId: Int64, year: Int32, month: Int32) async throws -> [MonthlyHistoryItem] {
        let dtos = try await historyAPIService.fetchMonthlyHistory(memberId: memberId, year: year, month: month)

        // DTO를 Domain Entity로 변환
        return dtos.compactMap { dto in
            guard let historyId = dto.historyId,
                  let imageUrl = dto.firstImageUrl,
                  let date = dto.historyDate else {
                return nil
            }
            return MonthlyHistoryItem(
                historyId: historyId,
                firstImageUrl: imageUrl,
                historyDate: date
            )
        }
    }
}
