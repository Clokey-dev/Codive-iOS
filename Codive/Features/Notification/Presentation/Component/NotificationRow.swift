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
        Image(systemName: "person.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .foregroundStyle(Color.gray.opacity(0.3))
            .frame(width: profileImageSize, height: profileImageSize)
            .clipShape(Circle())
    }
}
