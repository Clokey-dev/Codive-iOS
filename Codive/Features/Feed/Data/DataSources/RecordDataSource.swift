//
//  RecordDataSource.swift
//  Codive
//
//  Created by 황상환 on 2025/11/22.
//

import Foundation

protocol RecordDataSource {
    func create(record: Record) async -> Bool
}

final class DefaultRecordDataSource: RecordDataSource {
    func create(record: Record) async -> Bool {
        print("Creating record on remote server: \(record)")
        return true
    }
}
