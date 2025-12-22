//
//  SpecificLookBook.swift
//  Codive
//
//  Created by 한금준 on 11/27/25.
//

import SwiftUI

/// 특정 룩북에 포함된 코디 목록을 보여주는 화면
/// - 역할:
///   - 선택된 룩북의 코디들을 그리드 형태로 표시
///   - 코디 좋아요(하트) 토글 처리
///   - 코디 상세 화면 및 코디 추가 화면으로 네비게이션
struct SpecificLookBook: View {

    // MARK: - State Object & Local State

    /// 화면 상태 및 비즈니스 로직을 담당하는 ViewModel
    @StateObject private var viewModel: SpecificLookBookViewModel

    /// 좋아요(하트) 상태 UI 반응성을 위한 로컬 상태
    @State private var likedCodyIds: Set<Int> = []

    // MARK: - Initializer

    /// View 생성자
    /// 외부에서 주입받은 ViewModel을 StateObject로 래핑한다.
    init(viewModel: SpecificLookBookViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            VStack(spacing: 0) {

                // MARK: Top Navigation Bar

                CustomNavigationBar(
                    title: "데이트 룩",
                    onBack: viewModel.handleBackTap,
                    rightButton: viewModel.isEditing
                    ? .text(
                        title: TextLiteral.Common.delete,
                        isEnabled: !viewModel.selectedCodiIds.isEmpty,
                        action: viewModel.handleCompleteAction
                    )
                    : .overflow(
                        menuType: .feed,
                        menuActions: [
                            { viewModel.navigateToAddCodi() },
                            { viewModel.handleDeleteAction() }
                        ]
                    )
                )
                .zIndex(10)
                .padding(.leading, 15)

                // MARK: Content Area

                ScrollView {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: 16),
                            count: 2
                        ),
                        spacing: 16
                    ) {
                        ForEach(viewModel.lookBookList) { lookbook in
                            LookBookCard(
                                imageURL: lookbook.imageURL,
                                cardTitle: lookbook.cardTitle,
                                iconType: viewModel.isEditing ? .checkmark : .heart,
                                isSelected: viewModel.isEditing
                                    ? viewModel.selectedCodiIds.contains(lookbook.id)
                                    : likedCodyIds.contains(lookbook.id)
                            ) {
                                if viewModel.isEditing {
                                    viewModel.toggleSelection(id: lookbook.id)
                                } else {
                                    handleLikeTap(codyId: lookbook.id)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if viewModel.isEditing {
                                    viewModel.toggleSelection(id: lookbook.id)
                                } else {
                                    viewModel.navigateToCodiDetail(codiId: lookbook.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                .onAppear {
                    if viewModel.lookBookList.isEmpty {
                        viewModel.fetchCodis()
                    }
                }
            }

            // MARK: Loading Overlay (LookBookView와 동일)

            if viewModel.isLoading {
                LoadingView(backgroundStyle: .white)
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .alert(
            TextLiteral.LookBook.alertDeleteTitle,
            isPresented: $viewModel.isShowingDeleteAlert
        ) {
            Button(TextLiteral.Common.delete, role: .destructive) {
                viewModel.beginDelete()
            }
            Button(TextLiteral.Common.cancel, role: .cancel) { }
        } message: {
            Text(TextLiteral.LookBook.alertDeleteSubTitle)
        }
    }

    // MARK: - Like Handling Logic

    private func handleLikeTap(codyId: Int) {
        let isCurrentlyLiked = likedCodyIds.contains(codyId)
        if isCurrentlyLiked {
            likedCodyIds.remove(codyId)
        } else {
            likedCodyIds.insert(codyId)
        }
        viewModel.toggleLike(codyId: codyId, isLiked: !isCurrentlyLiked)
    }
}
