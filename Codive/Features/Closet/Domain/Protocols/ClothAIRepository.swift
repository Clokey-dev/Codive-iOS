//
//  ClothAIRepository.swift
//  Codive
//
//  Created by 황상환 on 2/17/26.
//

import Foundation

/// AI 옷 정보 추출 관련 Repository 인터페이스 (Domain Layer)
protocol ClothAIRepository {
    /// 이미지를 S3에 병렬 업로드합니다. 실패한 이미지는 nil로 반환합니다.
    func uploadImages(images: [Data]) async -> [String?]

    /// 이미지에서 옷 정보(누끼/카테고리/계절)를 추출합니다.
    func extractClothInfo(clothImageUrls: [String]) async throws -> [ClothAIInfo]

    /// 이미 업로드된 이미지 URL로 옷을 생성합니다.
    func createClothesWithUrls(requests: [ClothCreateAPIRequest]) async throws -> [Int64]
}
