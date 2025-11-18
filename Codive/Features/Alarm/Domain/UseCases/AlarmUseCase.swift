//
//  AlarmUseCase.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

final class AlarmUseCase {
    private let repository: AlarmRepository
    
    init(repository: AlarmRepository) {
        self.repository = repository
    }
}
