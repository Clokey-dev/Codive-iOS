//
//  SpecificLookBook.swift
//  Codive
//
//  Created by 한금준 on 11/27/25.
//

import SwiftUI

struct SpecificLookBook: View {
    @StateObject private var viewModel: SpecificLookBookViewModel
    @State private var selectedCodyIds: Set<Int> = []
    
    init(viewModel: SpecificLookBookViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                    ProgressView(TextLiteral.LookBook.loadingTitle).padding(.top, 100)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        ForEach(viewModel.lookBookList) { lookbook in
                            // 수정된 LookBookCard 사용
                            LookBookCard(
                                imageURL: lookbook.imageURL,
                                cardTitle: lookbook.cardTitle,
                                iconType: .heart,
                                isSelected: selectedCodyIds.contains(lookbook.id),
                                onIconTap: {
                                    // 하트 아이콘 클릭 시 동작
                                    handleCodyTap(codyId: lookbook.id)
                                }
                            )
                            .onTapGesture {
                                // 카드 전체 클릭 시 상세 페이지로 이동
                                viewModel.navigateToCodiDetail(codiId: lookbook.id)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .onAppear {
                if viewModel.lookBookList.isEmpty { viewModel.fetchCodis() }
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
        // ViewModel을 통한 서버 데이터 동기화
        viewModel.toggleLike(codyId: codyId, isLiked: !isCurrentlyLiked)
    }
}

#Preview {
    SpecificLookBook(viewModel: SpecificLookBookViewModel.preview)
}
