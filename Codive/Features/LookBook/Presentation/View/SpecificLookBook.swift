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

    // 좋아요(하트) 상태 UI 반응성을 위한 로컬 상태
    @State private var likedCodyIds: Set<Int> = []

    // MARK: - Initializer

    /// View 생성자
    /// 외부에서 주입받은 ViewModel을 StateObject로 래핑한다.
    init(viewModel: SpecificLookBookViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Top Navigation Bar

            /// 상단 네비게이션 바
            /// - 뒤로가기 버튼
            /// - 오버플로우 메뉴 (코디 추가 / 편집 액션)
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
                        { viewModel.handleDeleteAction() } // 편집하기 클릭 시 삭제 모드 진입
                    ]
                )
            )
            .zIndex(10)
            .padding(.leading, 15)

            // MARK: Content Area

            ScrollView {

                // MARK: Loading State

                /// 데이터 로딩 중 표시
                if viewModel.isLoading {
                    ProgressView(TextLiteral.LookBook.loadingTitle)
                        .padding(.top, 100)

                // MARK: Grid Content

                } else {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2),
                        spacing: 16
                    ) {
                        ForEach(viewModel.lookBookList) { lookbook in
                            
                            VStack(spacing: 0) {
                                // 편집 모드일 때는 체크마크, 아닐 때는 하트 표시
                                LookBookCard(
                                    imageURL: lookbook.imageURL,
                                    cardTitle: lookbook.cardTitle,
                                    iconType: viewModel.isEditing ? .checkmark : .heart,
                                    isSelected: viewModel.isEditing
                                        ? viewModel.selectedCodiIds.contains(lookbook.id)
                                        : likedCodyIds.contains(lookbook.id)
                                ) {
                                    // 우상단 아이콘(하트 혹은 체크박스) 클릭 시
                                    if viewModel.isEditing {
                                        viewModel.toggleSelection(id: lookbook.id)
                                    } else {
                                        handleLikeTap(codyId: lookbook.id)
                                    }
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // 카드 전체 클릭 시
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
            }

            // MARK: View Lifecycle

            /// 화면 진입 시 코디 목록 로드
            .onAppear {
                if viewModel.lookBookList.isEmpty {
                    viewModel.fetchCodis()
                }
            }
        }

        // MARK: - View Modifiers

        /// 기본 NavigationBar 숨김 (CustomNavigationBar 사용)
        .navigationBarHidden(true)

        /// 화면 배경색 설정
        .background(Color.white)
        // 삭제 확인 알림 추가
        .alert(
            TextLiteral.LookBook.alertDeleteTitle,
            isPresented: $viewModel.isShowingDeleteAlert
        ) {
            Button(TextLiteral.Common.delete, role: .destructive) {
                viewModel.confirmDelete()
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
