//
//  CreateRecordUseCase.swift
//  Codive
//
//  Created by gemini on 2025/11/22.
//

import Foundation

protocol CreateRecordUseCase {
    func create(record: Record) async -> Bool
}

final class DefaultCreateRecordUseCase: CreateRecordUseCase {
    private let repository: RecordRepository
    
    init(repository: RecordRepository) {
        self.repository = repository
    }
    
    func create(record: Record) async -> Bool {
        return await repository.create(record: record)
    }
}
