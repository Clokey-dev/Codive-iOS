//
//  AlarmView.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import SwiftUI

struct NotificationView: View {
    @StateObject private var viewModel: NotificationViewModel
    
    init(viewModel: NotificationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                title: TextLiteral.Notification.title) {
                    viewModel.handleBackTap()
                }
            
            ScrollView {
                VStack {
                    HStack {
                        Text(TextLiteral.Notification.notRead)
                            .font(Font.codive_body2_medium)
                            .foregroundStyle(Color.Codive.grayscale3)
                        Spacer()
                    }
                    .padding(.top, 32)
                    
                    HStack {
                        Text(TextLiteral.Notification.read)
                            .font(Font.codive_body2_medium)
                            .foregroundStyle(Color.Codive.grayscale3)
                        Spacer()
                    }
                    .padding(.top, 32)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea(.all))
    }
}

#Preview {
    NotificationView(viewModel: NotificationViewModel.preview)
}
