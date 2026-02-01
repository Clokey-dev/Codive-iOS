//
//  ProductUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/23/25.
//

import Foundation

final class ProductUseCase {

    // MARK: - Dependency
    private let repository: LookBookRepository

    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }

    // MARK: - Methods
    func execute(category: String? = nil) async throws -> [ProductItem] {
        return try await repository.fetchClothItems(category: category)
    }
    
    func execute(jpgData: Data) async throws -> String {
        print("--- 🚀 코디 이미지 업로드 시작 ---")
        
        guard !jpgData.isEmpty else {
            throw LookBookAPIError.invalidImageData
        }
        
        let uploadedURL = try await repository.uploadCodiImage(jpgData: jpgData)
        
        print("✅ 코디 이미지 업로드 성공")
        print("📍 Final URL: \(uploadedURL)")
        
        return uploadedURL
    }
}
