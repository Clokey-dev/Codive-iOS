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
                VStack(spacing: 0) {
                    if viewModel.isReported, let type = viewModel.reportType {
                        ReportSubmissionGuide(reportType: type)
                    }
                    
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
        .enableSwipeBack()
        .background(Color.white.ignoresSafeArea(.all))
        .highPriorityGesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 80 && abs(value.translation.height) < 50 {
                        viewModel.handleBackTap()
                    }
                }
        )
        // MARK: - Data Loading Trigger
        .onAppear {
            viewModel.loadData()
        }
    }
    
    // MARK: - View Builders
    @ViewBuilder
    private func notificationSection(
        title: String,
        notifications: [NotificationListResponseItem]
    ) -> some View {
        
        if !notifications.isEmpty {
            HStack {
                Text(title)
                    .font(Font.codive_body2_medium)
                    .foregroundStyle(Color.Codive.grayscale3)
                Spacer()
            }
            .padding(.top, 20)
            
            VStack(spacing: 16) {
                ForEach(notifications, id: \.notificationId) { item in
                    NotificationRow(notification: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if item.readStatus == .notRead {
                                viewModel.markAsRead(notificationId: item.notificationId)
                            }
                            // redirect 처리 위치
                        }
                }
            }
            .padding(.top, 12)
        }
    }
}
