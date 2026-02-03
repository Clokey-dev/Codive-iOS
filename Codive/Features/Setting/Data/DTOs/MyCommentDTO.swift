//
//  MyCommentDTO.swift
//  Codive
//

import Foundation

// MARK: - API Response
struct MyCommentsAPIResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let timeStamp: String
    let result: MyCommentsResult

    struct MyCommentsResult: Decodable {
        let content: [HistoryDTO]
        let isLast: Bool
    }
}

// MARK: - History DTO
struct HistoryDTO: Decodable {
    let historyId: Int64
    let imageUrl: String
    let nickname: String
    let historyDate: String
    let content: String?
    let payloads: [CommentPayloadDTO]

    struct CommentPayloadDTO: Decodable {
        let commentId: Int64
        let content: String?
    }
}
