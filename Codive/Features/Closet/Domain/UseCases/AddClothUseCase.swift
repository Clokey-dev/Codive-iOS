//
//  AddClothUseCase.swift
//  Codive
//
//  Created by 황상환 on 11/26/25.
//

import Foundation

// MARK: - AddClothUseCase Protocol
protocol AddClothUseCase {
    /// 옷 정보를 저장합니다.
    /// - Parameters:
    ///   - inputs: 사용자가 입력한 옷 정보 배열
    ///   - images: 옷 이미지 데이터 배열
    /// - Returns: 저장된 옷 엔티티 배열
    func execute(inputs: [ClothInput], images: [Data]) async throws -> [Cloth]
}

// MARK: - DefaultAddClothUseCase
final class DefaultAddClothUseCase: AddClothUseCase {

    // MARK: - Properties
    private let repository: ClothRepository

    // MARK: - Initializer
    init(repository: ClothRepository) {
        self.repository = repository
    }

    // MARK: - Methods
    func execute(inputs: [ClothInput], images: [Data]) async throws -> [Cloth] {
        return try await repository.saveClothes(inputs, images: images)
    }
}
