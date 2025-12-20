//
//  AddBeforeCodiView.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

/// 코디 추가 전 단계에서 이전 코디를 선택하는 화면
/// - 역할:
///   - 이전에 저장된 코디 목록을 그리드 형태로 표시
///   - 코디 선택 시 즉시 AddCodiView로 이동
///   - 로딩 / 에러 / 빈 상태 UI 처리
struct AddBeforeCodiView: View {

    // MARK: - Properties

    /// 화면 상태 및 비즈니스 로직을 담당하는 ViewModel
    /// View 생명주기 동안 유지되도록 StateObject 사용
    @StateObject private var viewModel: AddBeforeCodiViewModel

    // MARK: - Initializer

    /// View 생성자
    /// 외부에서 주입받은 ViewModel을 StateObject로 래핑한다.
    init(viewModel: AddBeforeCodiViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Navigation Bar

            /// 상단 네비게이션 바
            /// 뒤로가기 버튼을 통해 이전 화면으로 이동
            CustomNavigationBar(
                title: "이전 코디",
                onBack: viewModel.handleBackTap
            )

            // MARK: Content

            ScrollView {

                // MARK: Loading State

                /// 데이터 로딩 중 표시
                if viewModel.isLoading {
                    ProgressView(TextLiteral.LookBook.loadingTitle)
                        .padding(.top, 100)

                // MARK: Error State

                /// 에러 발생 시 메시지 표시
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()

                // MARK: Empty State

                /// 이전 코디가 하나도 없을 경우 표시
                } else if viewModel.lookBookList.isEmpty {
                    Text("해당 룩북에 코디가 없습니다.")
                        .foregroundColor(.gray)
                        .padding(.top, 100)

                // MARK: Codi Grid

                /// 이전 코디 목록 그리드 표시
                } else {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: 16),
                            count: 2
                        ),
                        spacing: 16
                    ) {
                        ForEach(viewModel.lookBookList) { lookbook in
                            BeforeCodiCard(
                                imageURL: lookbook.imageURL,
                                date: lookbook.date,
                                isSelected: false // 즉시 이동 구조이므로 선택 상태 미사용
                            )
                            .onTapGesture {
                                // 코디 선택 시 AddCodiView로 이동
                                viewModel.toggleSelection(id: lookbook.id)
                            }
                        }
                    }
                    .padding([.horizontal, .top], 16)
                }
            }
        }
        // MARK: - View Modifiers

        /// 기본 NavigationBar 숨김 (CustomNavigationBar 사용)
        .navigationBarHidden(true)

        /// 화면 배경색 설정
        .background(Color.white)

        /// 화면 진입 시 이전 코디 목록 로드
        .onAppear {
            viewModel.fetchLookBooks()
        }
    }
}

// MARK: - Preview

#Preview {
    AddBeforeCodiView(
        viewModel: AddBeforeCodiViewModel.preview
    )
}
