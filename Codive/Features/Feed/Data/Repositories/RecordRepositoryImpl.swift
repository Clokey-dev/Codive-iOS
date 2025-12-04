//
//  RecordRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 2025/11/22.
//

import Foundation

final class DefaultRecordRepository: RecordRepository {
    private let dataSource: RecordDataSource
    
    init(dataSource: RecordDataSource) {
        self.dataSource = dataSource
    }
    
    func create(record: Record) async -> Bool {
        return await dataSource.create(record: record)
    }
}
