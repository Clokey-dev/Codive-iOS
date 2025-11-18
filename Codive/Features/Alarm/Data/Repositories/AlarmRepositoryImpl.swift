//
//  AlarmRepositoryImpl.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

final class AlarmRepositoryImpl: AlarmRepository {
    private let datasource: AlarmDataSource
    
    init(datasource: AlarmDataSource) {
        self.datasource = datasource
    }
}
