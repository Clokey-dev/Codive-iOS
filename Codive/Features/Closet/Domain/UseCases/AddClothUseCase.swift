//
//  AddClothUseCase.swift
//  Codive
//
//  Created by Claude on 11/26/25.
//

import Foundation
import UIKit

/// 옷 추가 UseCase
final class AddClothUseCase {

    // MARK: - Properties
    private let repository: ClothRepository

    // MARK: - Initializer
    init(repository: ClothRepository) {
        self.repository = repository
    }

    // MARK: - Methods

    /// 옷 정보를 저장합니다.
    /// - Parameters:
    ///   - clothForms: 사용자가 입력한 옷 정보 배열
    ///   - images: 옷 이미지 배열
    /// - Returns: 저장된 옷 엔티티 배열
    func execute(
        clothForms: [ClothFormData],
        images: [UIImage]
    ) async throws -> [Cloth] {
        return try await repository.saveClothes(clothForms, images: images)
    }
}
