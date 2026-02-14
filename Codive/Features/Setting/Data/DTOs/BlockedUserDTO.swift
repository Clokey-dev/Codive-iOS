//
//  BlockedUserDTO.swift
//  Codive
//

import Foundation

// MARK: - Blocked Members API Response
struct BlockedMembersAPIResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let timeStamp: String
    let result: BlockedMembersResult

    struct BlockedMembersResult: Decodable {
        let content: [BlockedMemberDTO]
        let isLast: Bool
    }
}

// MARK: - Blocked Member DTO
struct BlockedMemberDTO: Decodable {
    let blockId: Int64
    let memberId: Int64
    let nickname: String
    let profileImageUrl: String?
}
