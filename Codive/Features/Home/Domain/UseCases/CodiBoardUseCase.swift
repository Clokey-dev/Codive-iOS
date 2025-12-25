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

    func loadCodiBoardImages() -> [DraggableImageEntity] {
        return repository.fetchInitialImages()
    }

    func saveCodiItems(_ images: [DraggableImageEntity]) async throws {
        // TODO: 실제 캔버스를 캡처한 이미지의 S3 업로드 URL이 이곳에 들어가야 함
        let mockSnapshotUrl = "https://codive-storage.com/previews/\(UUID().uuidString).jpg"
        
        // Entity를 DTO로 변환 (서버 스펙에 맞춤)
        let payloads: [CodiCoordinatePayloadDTO] = images.enumerated().map { index, image in
            return CodiCoordinatePayloadDTO(
                clothId: Int64(image.id), // 고유 의류 ID
                locationX: Double(image.position.x),
                locationY: Double(image.position.y),
                ratio: Double(image.scale),
                degree: Double(image.rotationAngle),
                order: index // 레이어 순서 (Z-Index가 높을수록 뒤에 위치함)
            )
        }
        
        let request = CodiCoordinateRequestDTO(
            coordinateImageUrl: mockSnapshotUrl,
            Payload: payloads
        )
        
        // Repository를 통해 서버(또는 Mock)에 저장
        try await repository.saveCodiCoordinate(request)
    }
}
