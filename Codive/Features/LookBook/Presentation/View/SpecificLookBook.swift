//
//  SpecificLookBook.swift
//  Codive
//
//  Created by 한금준 on 11/27/25.
//

import SwiftUI

struct SpecificLookBook: View {
    // MARK: - Properties
    @StateObject private var viewModel: SpecificLookBookViewModel
    
    // MARK: - Initializer
    init(viewModel: SpecificLookBookViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                title: "데이트 룩",
                onBack: { print("뒤로가기") },
                rightButton: .overflow(
                        menuType: .feed,
                        menuActions: [
                            { print("코디 추가하기 tapped") },
                            { print("편집하기 tapped") }
                        ]
                    )
            )
            .zIndex(10)
            .padding(.leading, 15)
            
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
                                    iconType: .heart
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
    SpecificLookBook(viewModel: SpecificLookBookViewModel.preview)
}
