//
//  NotificationRow.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import SwiftUI

struct NotificationRow: View {
    let notification: NotificationListResponseItem
    
    private let profileImageSize: CGFloat = 36
    
    // MARK: - RedirectType 기반 에셋 매핑
    private var typeSpecificImageName: String? {
        switch notification.action.redirectType {
        case .historyRedirect:
            return "history"
        case .memberRedirect:
            return nil
        case .none:
            return "weather"
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
            } else if !notification.notificationImageUrl.isEmpty,
                      let url = URL(string: notification.notificationImageUrl) {
                
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        defaultImage
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: profileImageSize, height: profileImageSize)
                .clipShape(Circle())
            } else {
                defaultImage
            }
            
            Text(notification.notificationContent)
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
