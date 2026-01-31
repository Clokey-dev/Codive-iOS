//
//  NotificationRow.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import SwiftUI

struct NotificationRow: View {
    let entity: NotificationEntity
    
    private let profileImageSize: CGFloat = 36
    
    // MARK: - Asset Logic
    /// 타입별 전용 에셋 이미지 이름 반환
    private var typeSpecificImageName: String? {
        switch entity.redirectType {
        case .history:
            return "history"
        case .weather:
            return "weather"
        case .member:
            return nil
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            if let imageName = typeSpecificImageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: profileImageSize, height: profileImageSize)
                    .clipShape(Circle())
            } else if let urlString = entity.notificationImageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        defaultImage // URL 에러 시 기본 이미지
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: profileImageSize, height: profileImageSize)
                .clipShape(Circle())
            } else {
                defaultImage // 이미지 URL이 nil인 경우
            }
            
            Text(entity.notificationContent)
                .font(Font.codive_body2_regular)
                .foregroundStyle(Color.Codive.grayscale1)
            
            Spacer()
        }
    }
    
    private var defaultImage: some View {
        Image("Profile")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: profileImageSize, height: profileImageSize)
            .clipShape(Circle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        NotificationRow(entity: NotificationEntity(
            notificationId: 1,
            notificationImageUrl: "https://picsum.photos/id/237/200/200",
            notificationContent: "홍길동님이 회원님의 옷장을 팔로우하기 시작했습니다.",
            redirectInfo: "user_123",
            redirectType: .member,
            readStatus: .unread,
            createdAt: "2025-11-18T10:00:00"
        ))

        NotificationRow(entity: NotificationEntity(
            notificationId: 2,
            notificationImageUrl: nil,
            notificationContent: "김철수님이 새로운 게시물을 업로드했습니다.",
            redirectInfo: "post_456",
            redirectType: .history,
            readStatus: .unread,
            createdAt: "2025-11-18T11:00:00"
        ))

        NotificationRow(entity: NotificationEntity(
            notificationId: 3,
            notificationImageUrl: "invalid_url",
            notificationContent: "내일은 비 소식이 있습니다. 우산을 준비하세요!",
            redirectInfo: "seoul",
            redirectType: .weather,
            readStatus: .read,
            createdAt: "2025-11-18T12:00:00"
        ))
    }
    .padding()
}
