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
                title: TextLiteral.LookBook.title,
                onBack: { print("뒤로가기") },
                rightButton: .menu(
                    systemName: "ellipsis",
                    isEnabled: true
                ) {
                    print("메뉴 버튼")
                }
            )
            
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("룩북 로드 중...")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                            ForEach(viewModel.lookBookList) { lookbook in
                                LookBookCard(
                                    imageURL: lookbook.imageURL,
                                    cardTitle: lookbook.cardTitle,
                                    iconType: .none
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .onAppear {
                        if viewModel.lookBookList.isEmpty {
                            viewModel.fetchLookBooks()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LookBookView(viewModel: LookBookViewModel.preview)
}
