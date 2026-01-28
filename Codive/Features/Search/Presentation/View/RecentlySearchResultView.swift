//
//  RecentlySearchResultView.swift
//  Codive
//
//  Created by 한금준 on 1/29/26.
//

import SwiftUI

struct RecentlySearchResultView: View {
    // MARK: - Properties
    @StateObject private var viewModel: RecentlySearchResultViewModel
    
    // MARK: - Initializer
    init(viewModel: RecentlySearchResultViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                title: "완료 버튼",
                onBack: { },
                rightButton: .text(title: "전체삭제", isEnabled: true) {
                    viewModel.handleDeleteAll()
                }
            )
            .padding(.horizontal, 15)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.items) { item in
                        RecentlySearchResultRow(
                            type: {
                                switch item {
                                case .hashTag(let title):
                                    return .hashTag(title: title)
                                case .member(let imageUrl, let title, let subtitle):
                                    return .member(
                                        imageUrl: imageUrl,
                                        title: title,
                                        subtitle: subtitle
                                    )
                                }
                            }()
                        ) {
                            viewModel.deleteTag()
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea(.all))
        // MARK: - Alert
        .alert(
            TextLiteral.Search.alertTitle,
            isPresented: $viewModel.showingDeleteAlert
        ) {
            Button(TextLiteral.Search.alertDelete, role: .destructive) {
                viewModel.executeDeleteAll()
            }
            Button(TextLiteral.Search.alertCancel, role: .cancel) {}
        } message: {
            Text(TextLiteral.Search.noRestore)
        }
    }
}

#Preview {
    RecentlySearchResultView(
        viewModel: RecentlySearchResultViewModel(
            navigationRouter: NavigationRouter()
        )
    )
}
