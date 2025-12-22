//
//  EditCodiView.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

/// 코디 수정 화면
/// - 역할:
///   - 기존 코디 정보(이미지 / 이름 / 메모)를 불러와 편집
///   - 수정 사항 유무에 따라 네비게이션 바 UI를 동적으로 변경
///   - 수정 완료 시 ViewModel을 통해 저장 및 뒤로 이동
struct EditCodiView: View {

    // MARK: - State Object

    /// 화면 상태 및 비즈니스 로직을 담당하는 ViewModel
    /// View 생명주기 동안 유지되도록 StateObject 사용
    @StateObject private var viewModel: EditCodiViewModel

    // MARK: - Initializer

    /// View 생성자
    /// 외부에서 주입받은 ViewModel을 StateObject로 래핑한다.
    init(viewModel: EditCodiViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Conditional Navigation Bar

            /// 수정 여부에 따라 네비게이션 바 UI를 분기
            /// - 수정 사항 있음 → 완료 버튼 노출
            /// - 수정 사항 없음 → 기본 뒤로가기만 제공
            if viewModel.hasChanges {

                // MARK: Navigation Bar (With Changes)

                CustomNavigationBar(
                    title: viewModel.codiName, // 코디 명 실시간 반영
                    onBack: { viewModel.handleBackTap() },
                    rightButton: .text(
                        title: TextLiteral.Common.complete,
                        isEnabled: viewModel.isButtonEnabled,
                        action: viewModel.handleCompleteTap
                    )
                )
                .padding(.leading, 15)
            } else {

                // MARK: Navigation Bar (No Changes)

                CustomNavigationBar(
                    title: viewModel.codiName
                ) {
                    viewModel.handleBackTap()
                }
                .padding(.leading, 15)
            }

            // MARK: - Scrollable Content

            ScrollView {
                VStack(spacing: 24) {

                    // MARK: Image Preview Area

                    /// 코디 대표 이미지 표시 영역
                    /// - 서버에서 불러온 이미지 표시
                    /// - 이미지 위에 수정 상태를 나타내는 오버레이 표시
                    ZStack {
                        if let url = viewModel.selectedImageURL {
                            AsyncImage(url: URL(string: url)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    Color.gray.opacity(0.2)
                                }
                            }
                            .frame(height: 335)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            // MARK: Animation Overlay

                            /// 수정 중임을 시각적으로 나타내는 오버레이
                            EditCodiOverlayView()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .frame(height: 335)

                    // MARK: Codi Information Input

                    /// 코디 이름 / 개인 메모 입력 영역
                    VStack(spacing: 12) {
                        CustomTextField1(
                            title: TextLiteral.LookBook.codiNameTitle,
                            placeholder: TextLiteral.LookBook.hintCodiNameTitle,
                            text: $viewModel.codiName,
                            showRequiredMark: true
                        )

                        CustomTextField1(
                            title: TextLiteral.LookBook.memoTitle,
                            placeholder: TextLiteral.LookBook.hintMemo,
                            text: $viewModel.memo
                        )
                    }
                }
                .padding(20)
            }

            // MARK: - Bottom Action Button

            /// 수정 완료 버튼
            /// - 수정 조건 충족 시에만 활성화
            CustomButton(
                text: TextLiteral.LookBook.editCodiComplete,
                widthType: .fixed,
                isEnabled: viewModel.isButtonEnabled
            ) {
                viewModel.handleCompleteTap()
            }
            .padding(20)
        }

        // MARK: - View Modifiers

        /// 기본 NavigationBar 숨김 (CustomNavigationBar 사용)
        .navigationBarHidden(true)

        /// 화면 배경색 설정
        .background(Color.white)
    }
}
