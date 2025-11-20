//
//  NotificationDataSource.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import Foundation

final class NotificationDataSource {
    
    func fetchNotifications() -> [NotificationEntity] {
        return [
            NotificationEntity(
                id: 1,
                imageUrl: "https://picsum.photos/id/237/200/200",
                message: "홍길동님이 회원님의 옷장을 팔로우하기 시작했습니다.",
                isRead: false
            ),
            NotificationEntity(
                id: 2,
                imageUrl: nil,
                message: "김철수님이 새로운 게시물을 업로드했습니다.",
                isRead: false
            ),
            NotificationEntity(
                id: 3,
                imageUrl: "invalid_url",
                message: "이영희님이 회원님의 게시물에 좋아요를 눌렀습니다.",
                isRead: false
            ),
            NotificationEntity(
                id: 4,
                imageUrl: "https://picsum.photos/id/100/200/200",
                message: "박민수님이 회원님의 댓글에 답글을 달았습니다.",
                isRead: true
            ),
            NotificationEntity(
                id: 5,
                imageUrl: nil,
                message: "코디 추천 시즌 이벤트가 시작되었습니다.",
                isRead: true
            )
        ]
    }
}
