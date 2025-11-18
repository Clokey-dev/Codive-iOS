//
//  AlarmView.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import SwiftUI

struct AlarmView: View {
    @StateObject private var viewModel: AlarmViewModel
    
    init(viewModel: AlarmViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                title: TextLiteral.Alarm.title) {
                    viewModel.handleBackTap()
                }
            
            ScrollView {
                VStack {
                    Text("알림")
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea(.all))
        .padding(.horizontal, 20)
    }
}

#Preview {
    AlarmView(viewModel: AlarmViewModel.preview)
}
