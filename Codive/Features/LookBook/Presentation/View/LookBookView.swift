//
//  LookBookView.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import SwiftUI

struct LookBookView: View {
    // MARK: - Properties
    @StateObject private var viewModel: LookBookViewModel
    
    // MARK: - Initializer
    init(viewModel: LookBookViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                title: TextLiteral.Notification.title) {
                    viewModel.handleBackTap()
                }
            ScrollView {
                
            }
        }
    }
}

#Preview {
    LookBookView(viewModel: LookBookViewModel.preview)
}
