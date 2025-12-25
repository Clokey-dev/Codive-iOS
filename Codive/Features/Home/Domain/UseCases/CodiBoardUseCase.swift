//
//  CodiBoardUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/25/25.
//

final class CodiBoardUseCase {

    private let repository: HomeRepository

    init(repository: HomeRepository) {
        self.repository = repository
    }

    func loadCodiBoardImages() -> [DraggableImageEntity] {
        return repository.fetchInitialImages()
    }

    func saveCodiItems(_ images: [DraggableImageEntity]) {
        // TODO: 실제 스냅샷 URL을 전달받도록 변경 예정 (현재는 mock URL 사용)
        let mockCoordinateImageUrl = "https://example.com/mock-today-codi-snapshot.jpg"
        
        let payloads: [CodiCoordinatePayloadDTO] = images.enumerated().map { index, image in
            CodiCoordinatePayloadDTO(
                clothId: Int64(image.id),                    // 실제 clothId 필드가 생기면 교체
                locationX: Double(image.position.x),
                locationY: Double(image.position.y),
                ratio: Double(image.scale),
                degree: image.rotationAngle,
                order: index
            )
        }
        
        let request = CodiCoordinateRequestDTO(
            coordinateImageUrl: mockCoordinateImageUrl,
            Payload: payloads
        )
        
        repository.saveCodiCoordinate(request)
    }
}
