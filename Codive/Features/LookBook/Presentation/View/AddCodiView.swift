//
//  AddCodiView.swift
//  Codive
//
//  Created by 한금준 on 11/25/25.
//

import SwiftUI

/// 코디 추가 화면
/// - 역할:
///   - 신규 코디 생성 / 기존 코디 불러오기 결과를 표시
///   - 코디 이미지(조합 결과 또는 대표 이미지) 미리보기
///   - 코디 이름 / 메모 입력
///   - 하단 바텀시트를 통한 코디 생성 방식 선택
///   - 코디 추가 완료 처리 및 성공 화면 표시
struct AddCodiView: View {

    // MARK: - State Object

    /// 화면 상태 및 비즈니스 로직을 담당하는 ViewModel
    /// View 생명주기 동안 유지되도록 StateObject 사용
    @StateObject private var viewModel: AddCodiViewModel

    // MARK: - Initializer

    /// View 생성자
    /// 외부에서 주입받은 ViewModel을 StateObject로 래핑한다.
    init(viewModel: AddCodiViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ZStack {

            // MARK: Main Content

            VStack(spacing: 0) {

                // MARK: Top Navigation Bar

                /// 상단 네비게이션 바
                /// - 뒤로가기 버튼 제공
                CustomNavigationBar(
                    title: TextLiteral.LookBook.addCodiTitle,
                    onBack: viewModel.handleBackTap
                )
                .padding(.leading, 15)

                // MARK: Scrollable Content

                ScrollView {
                    VStack(spacing: 24) {

                        // MARK: Codi Image Preview Area

                        /// 코디 이미지 영역
                        /// - 직접 조합한 아이템이 있으면 보드 형태로 표시
                        /// - 기존 코디 불러오기 시 대표 이미지 표시
                        /// - 아무 것도 없을 경우 업로드 버튼 표시
                        ZStack {
                            if !viewModel.combinedItems.isEmpty {

                                // MARK: Combined Codi Board

                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color(UIColor.systemGray6))

                                    /// 조합된 아이템 미리보기
                                    ForEach(viewModel.combinedItems) { item in
                                        AsyncImage(url: URL(string: item.name)) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                            }
                                        }
                                        .frame(width: 80, height: 80)
                                        .scaleEffect(item.scale)
                                        .rotationEffect(.degrees(item.rotationAngle))
                                        .position(x: item.position.x, y: item.position.y)
                                    }

                                    /// 편집 오버레이 UI
                                    EditCodiOverlayView()
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            } else if let imageURL = viewModel.selectedImageURL, !imageURL.isEmpty {

                                // MARK: Selected Image Preview

                                AsyncImage(url: URL(string: imageURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 335)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    case .failure:
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    case .empty:
                                        ProgressView()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 335)
                                    .overlay {
                                        CustomButton(
                                            text: TextLiteral.LookBook.codiUpload,
                                            widthType: .dynamic
                                        ) {
                                            viewModel.handleCodiUploadTap()
                                        }
                                    }
                            }
                        }
                        .frame(height: 335)

                        // MARK: Codi Information Input

                        /// 코디 이름 / 메모 입력 영역
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

                // MARK: Bottom Action Button

                /// 코디 추가 완료 버튼
                /// - 입력 조건 충족 시에만 활성화
                CustomButton(
                    text: TextLiteral.LookBook.addCodiCompleteButton,
                    widthType: .fixed,
                    isEnabled: viewModel.isButtonEnabled
                ) {
                    viewModel.handleCompleteTap()
                }
                .padding(20)
            }
            .disabled(viewModel.isShowingBottomSheet)

            // MARK: Bottom Sheet Overlay

            /// 신규 코디 생성 / 이전 코디 불러오기 선택 바텀시트
            if viewModel.isShowingBottomSheet {
                bottomSheetOverlay
            }
        }

        // MARK: - View Modifiers

        /// 기본 NavigationBar 숨김 (CustomNavigationBar 사용)
        .navigationBarHidden(true)

        /// 화면 배경색 설정
        .background(Color.white)

        /// 코디 추가 성공 시 풀스크린 성공 화면 표시
        .fullScreenCover(isPresented: $viewModel.isShowingSuccessView) {
            CustomSuccessView(message: viewModel.successMessage)
        }
    }

    // MARK: - Bottom Sheet Overlay View

    /// 바텀시트 + 배경 오버레이 뷰
    private var bottomSheetOverlay: some View {
        ZStack {

            // MARK: Dimmed Background

            /// 바텀시트 외부 터치 시 닫힘 처리
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    viewModel.isShowingBottomSheet = false
                }

            // MARK: Bottom Sheet Content

            VStack {
                Spacer()
                CustomBottomSheet(
                    iconName1: "plus",
                    iconName2: "clo_selected",
                    title1: TextLiteral.LookBook.addNewCodi,
                    title2: TextLiteral.LookBook.getBeforeCodi,
                    action1: { viewModel.navigateToNewCodi() },
                    action2: { viewModel.handleRecallCodi() }
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddCodiView(viewModel: AddCodiViewModel.preview)
}
