//
//  TopNavigationBar.swift
//  Codive
//
//  Created by 황상환 on 9/22/25.
//

import SwiftUI

struct TopNavigationBar: View {
    
    // MARK: - Properties
    let showSearchButton: Bool
    let showNotificationButton: Bool
    let hasUnreadNotification: Bool
    let onSearchTap: (() -> Void)?
    let onNotificationTap: (() -> Void)?
    
    // MARK: - Initializer
    init(
        showSearchButton: Bool = true,
        showNotificationButton: Bool = true,
        hasUnreadNotification: Bool = false,
        onSearchTap: (() -> Void)? = nil,
        onNotificationTap: (() -> Void)? = nil
    ) {
        self.showSearchButton = showSearchButton
        self.showNotificationButton = showNotificationButton
        self.hasUnreadNotification = hasUnreadNotification
        self.onSearchTap = onSearchTap
        self.onNotificationTap = onNotificationTap
    }
    
    // MARK: - Body
    var body: some View {
        HStack {
            // Logo Image
            Image("codive_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 25)
            
            Spacer()
                        
            HStack(spacing: 16) {
                if showSearchButton {
                    Button {
                        onSearchTap?()
                    } label: {
                        Image("search")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(Color.Codive.grayscale1)
                            .frame(width: 20, height: 20)
                    }
                }
                
                // Notification Button
                if showNotificationButton {
                    Button {
                        onNotificationTap?()
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(hasUnreadNotification ? "alert_on" : "alert_off")
                                .renderingMode(.template)
                                .resizable()
                                .foregroundStyle(Color.Codive.grayscale1)
                                .frame(width: 18, height: 21)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

#Preview {
    VStack(spacing: 0) {
        TopNavigationBar(
            onSearchTap: {
                print("Search tapped")
            },
            onNotificationTap: {
                print("Notification tapped")
            }
        )
        
        Spacer()
    }
    .background(Color.gray.opacity(0.1))
}
