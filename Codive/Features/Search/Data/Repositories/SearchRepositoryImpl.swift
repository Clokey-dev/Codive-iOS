//
//  SearchRepositoryImpl.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

final class SearchRepositoryImpl: SearchRepository {
    private let datasource: SearchDataSource
    
    init(datasource: SearchDataSource) {
        self.datasource = datasource
    }
}
