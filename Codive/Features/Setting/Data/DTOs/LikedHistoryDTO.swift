import Foundation

// MARK: - Liked Records DTO
struct LikedHistoryDTO: Decodable {
    let id: Int64
    let imageUrl: String
    let historyDate: String
    let lastLikeId: Int64?
}
