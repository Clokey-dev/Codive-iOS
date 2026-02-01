import Foundation

// MARK: - API Response DTOs

struct LikedHistoryPreviewDTO: Decodable {
    let id: Int64
    let imageUrl: String
    let historyDate: Date
    let lastLikeId: Int64

    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl
        case historyDate
        case lastLikeId
    }
}

struct SliceResponseDTO: Decodable {
    let content: [LikedHistoryPreviewDTO]
    let isLast: Bool
}

struct BaseResponseSliceDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let timeStamp: Date
    let result: SliceResponseDTO
}
