//
//  NotificationDataSource.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import Foundation

final class NotificationDataSource {
    
    // MARK: - Fetch Methods
    
    func fetchNotifications() -> [NotificationEntity] {
        return [
            NotificationEntity(
                notificationId: 1,
                notificationImageUrl: "https://picsum.photos/id/237/200/200",
                notificationContent: "홍길동님이 회원님의 옷장을 팔로우하기 시작했습니다.",
                redirectInfo: "user_123",
                redirectType: .member,
                readStatus: .unread,
                createdAt: "2025-11-18T10:00:00"
            ),
            NotificationEntity(
                notificationId: 2,
                notificationImageUrl: nil,
                notificationContent: "1년 전 오늘의 기록을 확인해보세요.",
                redirectInfo: "post_456",
                redirectType: .history,
                readStatus: .unread,
                createdAt: "2025-11-18T11:00:00"
            ),
            NotificationEntity(
                notificationId: 3,
                notificationImageUrl: "https://picsum.photos/id/100/200/200",
                notificationContent: "내일은 비가 올 예정입니다. 우산을 챙기세요!",
                redirectInfo: "seoul",
                redirectType: .weather,
                readStatus: .read,
                createdAt: "2025-11-18T12:00:00"
            ),
            NotificationEntity(
                notificationId: 4,
                notificationImageUrl: nil,
                notificationContent: "홍길동님이 팔로우를 취소했습니다.",
                redirectInfo: "user_123",
                redirectType: .member,
                readStatus: .unread,
                createdAt: "2025-11-18T10:00:00"
            ),
            NotificationEntity(
                notificationId: 6,
                notificationImageUrl: nil,
                notificationContent: "내일은 비가 올 예정입니다. 우산을 챙기세요!",
                redirectInfo: "Busan",
                redirectType: .weather,
                readStatus: .unread,
                createdAt: "2025-11-18T12:00:00"
            )
        ]
    }
}
