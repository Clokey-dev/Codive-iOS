//
//  RecordRepository.swift
//  Codive
//
//  Created by 황상환 on 2025/11/22.
//

import Foundation

protocol RecordRepository {
    func create(record: Record) async -> Bool
}
