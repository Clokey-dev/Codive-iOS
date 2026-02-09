//
//  CodiBoardUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/25/25.
//

import Foundation

final class CodiBoardUseCase {

    private let repository: HomeRepository

    init(repository: HomeRepository) {
        self.repository = repository
    }
}
