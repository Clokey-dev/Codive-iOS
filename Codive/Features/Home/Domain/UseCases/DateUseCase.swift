//
//  DateUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/25/25.
//

final class DateUseCase {

    private let repository: HomeRepository

    init(repository: HomeRepository) {
        self.repository = repository
    }

    func getToday() -> DateEntity {
        return repository.getToday()
    }
}
