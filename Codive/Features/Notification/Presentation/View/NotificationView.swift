//
//  NotificationView.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import SwiftUI

struct NotificationView: View {
    // MARK: - Properties
    @StateObject private var viewModel: NotificationViewModel
    
    // MARK: - Initializer
    init(viewModel: NotificationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            CustomNavigationBar(
                title: TextLiteral.Notification.title) {
                    viewModel.handleBackTap()
                }
            
            ScrollView {
                VStack {
                    // MARK: - Notification Sections
                    notificationSection(
                        title: TextLiteral.Notification.notRead,
                        notifications: viewModel.unreadNotifications
                    )
                    notificationSection(
                        title: TextLiteral.Notification.read,
                        notifications: viewModel.readNotifications
                    )
                    
                    if viewModel.unreadNotifications.isEmpty && viewModel.readNotifications.isEmpty {
                        Text(TextLiteral.Notification.noNewNoti)
                            .padding(.top, 50)
                            .foregroundStyle(Color.Codive.grayscale3)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea(.all))
        // MARK: - Data Loading Trigger
        .onAppear {
            viewModel.loadData()
        }
    }
    
    // MARK: - View Builders
    @ViewBuilder
    private func notificationSection(title: String, notifications: [NotificationEntity]) -> some View {
        if !notifications.isEmpty {
            HStack {
                Text(title)
                    .font(Font.codive_body2_medium)
                    .foregroundStyle(Color.Codive.grayscale3)
                Spacer()
            }
            .padding(.top, 32)

            VStack(spacing: 16) {
                ForEach(notifications) { item in
                    NotificationRow(
                        profileImageUrl: item.imageUrl,
                        message: item.message
                    )
                }
            }
            .padding(.top, 12)
        }
    }
}
