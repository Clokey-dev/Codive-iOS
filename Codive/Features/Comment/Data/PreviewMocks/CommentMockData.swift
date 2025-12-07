//
//  CommentMockData.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation

// Comment 피처에서 사용되는 모든 목업 데이터를 중앙 관리하는 구조체
struct CommentMockData {
    static let users: [User] = [
        .init(id: "1", nickname: "패셔니스타", profileImageUrl: "https://example.com/p1.jpg"),
        .init(id: "2", nickname: "코디장인", profileImageUrl: "https://example.com/p2.jpg"),
        .init(id: "3", nickname: "CurrentUser", profileImageUrl: nil),
        .init(id: "4", nickname: "궁금러", profileImageUrl: "https://example.com/p4.jpg")
    ]

    static let comments: [Comment] = [
        {
            var comment = Comment(
                id: 1,
                content: "와, 이 코디 정말 멋져요! 어디서 구매하셨나요? 정보가 너무 궁금하네요. 혹시 실례가 안된다면 정보 공유해주실 수 있을까요?",
                author: users[0],
                isMine: false,
                hasReplies: true
            )
            comment.replies = [
                .init(id: 101, content: "그러게요! 저도 궁금해요!", author: users[1], isMine: false),
                .init(id: 102, content: "상의 정보 알 수 있을까요?", author: users[0], isMine: true),
                .init(id: 103, content: "DM 확인해주세요~", author: users[3], isMine: false),
                .init(id: 104, content: "네, 확인했어요!", author: users[0], isMine: true)
            ]
            return comment
        }(),
        .init(id: 2, content: "신발 정보 좀 알 수 있을까요? 🥺", author: users[1], isMine: false, hasReplies: false)
    ]
}
