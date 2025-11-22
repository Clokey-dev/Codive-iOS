//
//  LookBookUseCase.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

final class LookBookUseCase {
    // MARK: - Properties
    private let repository: LookBookRepository
    
    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }
}
