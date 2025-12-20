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

    /// 좋아요(하트) 상태를 즉각적으로 반영하기 위한 로컬 상태
    /// ViewModel의 서버 상태와 별도로 UI 반응성을 위해 사용
    @State private var selectedCodyIds: Set<Int> = []

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
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: 16),
                            count: 2
                        ),
                        spacing: 16
                    ) {
                        ForEach(viewModel.lookBookList) { lookbook in

                            // MARK: Codi Card

                            /// 코디 카드
                            /// - 하트 버튼: 좋아요 토글
                            /// - 카드 전체 탭: 코디 상세 화면 이동
                            LookBookCard(
                                imageURL: lookbook.imageURL,
                                cardTitle: lookbook.cardTitle,
                                iconType: .heart,
                                isSelected: selectedCodyIds.contains(lookbook.id)
                            ) {
                                handleCodyTap(codyId: lookbook.id)
                            }
                            .onTapGesture {
                                // 카드 전체 클릭 시 코디 상세 화면으로 이동
                                viewModel.navigateToCodiDetail(codiId: lookbook.id)
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
    }

    // MARK: - Like Handling Logic

    /// 코디 좋아요(하트) 토글 처리
    /// - 로컬 상태를 먼저 변경해 UI 반응성을 확보
    /// - 이후 ViewModel을 통해 서버 상태와 동기화
    private func handleCodyTap(codyId: Int) {
        let isCurrentlyLiked = selectedCodyIds.contains(codyId)

        if isCurrentlyLiked {
            selectedCodyIds.remove(codyId)
        } else {
            selectedCodyIds.insert(codyId)
        }

        // ViewModel을 통한 서버 데이터 동기화
        viewModel.toggleLike(
            codyId: codyId,
            isLiked: !isCurrentlyLiked
        )
    }
}

// MARK: - Preview

#Preview {
    SpecificLookBook(
        viewModel: SpecificLookBookViewModel.preview
    )
}
