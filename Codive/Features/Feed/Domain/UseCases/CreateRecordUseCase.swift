//
//  CreateRecordUseCase.swift
//  Codive
//
//  Created by 황상환 on 2025/11/22.
//

import Foundation

protocol CreateRecordUseCase {
    func execute(request: RecordCreateRequest) async throws -> Int64
}

final class DefaultCreateRecordUseCase: CreateRecordUseCase {
    private let repository: RecordRepository

    init(repository: RecordRepository = DefaultRecordRepository()) {
        self.repository = repository
    }

    func execute(request: RecordCreateRequest) async throws -> Int64 {
        return try await repository.createRecord(request: request)
    }
}
