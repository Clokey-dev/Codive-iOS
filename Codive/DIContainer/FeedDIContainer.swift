//
//  FeedDIContainer.swift
//  Codive
//
//  Created by 황상환 on 2025/11/22.
//

import Foundation

final class FeedDIContainer {
    
    // MARK: - DataSources
    private lazy var recordDataSource: RecordDataSource = {
        return DefaultRecordDataSource()
    }()
    
    // MARK: - Repositories
    private lazy var recordRepository: RecordRepository = {
        return DefaultRecordRepository(dataSource: recordDataSource)
    }()
    
    // MARK: - UseCases
    func makeCreateRecordUseCase() -> CreateRecordUseCase {
        return DefaultCreateRecordUseCase(repository: recordRepository)
    }
}
