//
//  RecordRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 2025/11/22.
//

import Foundation

final class DefaultRecordRepository: RecordRepository {
    private let dataSource: RecordDataSource

    init(dataSource: RecordDataSource = DefaultRecordDataSource()) {
        self.dataSource = dataSource
    }

    func createRecord(request: RecordCreateRequest) async throws -> Int64 {
        return try await dataSource.createRecord(request: request)
    }
}
