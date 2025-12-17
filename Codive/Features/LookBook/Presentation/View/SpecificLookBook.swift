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
    @State private var selectedCodyIds: Set<Int> = []
    
    // MARK: - Initializer
    init(viewModel: SpecificLookBookViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) { // spacing을 0으로 설정하여 상단바와 밀착
            CustomNavigationBar(
                title: "데이트 룩",
                onBack: { viewModel.handleBackTap() },
                rightButton: .overflow(
                        menuType: .feed,
                        menuActions: [
                            { viewModel.navigateToAddCodi() },
                            { print("편집하기 tapped") }
                        ]
                    )
            )
            .zIndex(10)
            .padding(.leading, 15)
            
            ScrollView {
                if viewModel.isLoading {
                    ProgressView(TextLiteral.LookBook.loadingTitle)
                        .padding(.top, 100)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                } else if viewModel.lookBookList.isEmpty {
                    Text("해당 룩북에 코디가 없습니다.")
                        .foregroundColor(.gray)
                        .padding(.top, 100)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        ForEach(viewModel.lookBookList) { lookbook in
                            LookBookCard(
                                imageURL: lookbook.imageURL,
                                cardTitle: lookbook.cardTitle,
                                iconType: .heart,
                                isSelected: selectedCodyIds.contains(lookbook.id)
                            )
                            .onTapGesture {
                                handleCodyTap(codyId: lookbook.id)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .onAppear {
                if viewModel.lookBookList.isEmpty {
                    viewModel.fetchCodis()
                }
            }
        }
        .navigationBarHidden(true) 
        .background(Color.white)
    }

    private func handleCodyTap(codyId: Int) {
        let isCurrentlyLiked = selectedCodyIds.contains(codyId)

        if isCurrentlyLiked {
            selectedCodyIds.remove(codyId)
        } else {
            selectedCodyIds.insert(codyId)
        }

        viewModel.toggleLike(codyId: codyId, isLiked: !isCurrentlyLiked)
    }
}

#Preview {
    SpecificLookBook(viewModel: SpecificLookBookViewModel.preview)
}
