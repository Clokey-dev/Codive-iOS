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
        let mockSnapshotUrl = "https://codive-storage.com/previews/\(UUID().uuidString).jpg"
        
        let payloads: [CodiCoordinatePayloadDTO] = images.enumerated().map { index, image in
            return CodiCoordinatePayloadDTO(
                clothId: Int64(image.id),
                locationX: Double(image.position.x),
                locationY: Double(image.position.y),
                ratio: Double(image.scale),
                degree: Double(image.rotationAngle),
                order: index
            )
        }
        
        let request = CodiCoordinateRequestDTO(
            coordinateImageUrl: mockSnapshotUrl,
            Payload: payloads
        )

        try await repository.saveCodiCoordinate(request)
    }
}
