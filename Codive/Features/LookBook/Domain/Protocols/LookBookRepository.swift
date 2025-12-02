//
//  LookBookRepository.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

protocol LookBookRepository {
    func fetchLookBookList() async throws -> [LookBookEntity]
    func deleteLookBooks(ids: [String]) async throws
}
