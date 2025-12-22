//
//  AddCodiDetailView.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

/// 새로운 코디를 직접 조합하는 화면
/// - 역할:
///   - 상품을 선택해 드래그 가능한 이미지로 코디 보드에 배치
///   - 드래그 / 이동 / 확대 / 회전 인터랙션 제공
///   - 하단 바텀시트를 통해 상품 필터링 및 선택
///   - 조합 완료 시 AddCodiView로 결과 전달
struct AddCodiDetailView: View {

    // MARK: - State Object

    /// 화면 상태 및 비즈니스 로직을 담당하는 ViewModel
    /// View 생명주기 동안 유지되도록 StateObject 사용
    @StateObject private var viewModel: AddCodiDetailViewModel

    // MARK: - Initializer

    /// View 생성자
    /// 외부에서 주입받은 ViewModel을 StateObject로 래핑한다.
    init(viewModel: AddCodiDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Top Navigation Bar

            /// 상단 네비게이션 바
            /// - 뒤로가기 버튼
            /// - 선택된 상품이 있을 때만 활성화되는 완료 버튼
            CustomNavigationBar(
                title: TextLiteral.LookBook.makeNewCodi,
                onBack: viewModel.handleBackTap,
                rightButton: .text(
                    title: TextLiteral.Common.complete,
                    isEnabled: !viewModel.selectedProductIds.isEmpty,
                    action: viewModel.handleComplete
                )
            )
            .padding(.horizontal, 15)

            // MARK: Geometry Reader (Layout Calculation)

            /// 화면 크기를 기준으로 코디 보드 사이즈를 계산
            GeometryReader { geometry in
                let boardSize = geometry.size.width - 40
                let imageHalfSize: CGFloat = 40
                let minBound = imageHalfSize
                let maxBound = boardSize - imageHalfSize

                // MARK: Main Content ZStack

                ZStack(alignment: .bottom) {

                    // MARK: Background Content

                    VStack(spacing: 20) {

                        // MARK: Guide Text

                        /// 화면 상단 안내 문구
                        VStack(alignment: .leading, spacing: 4) {
                            Text(TextLiteral.LookBook.makeNewCodiDescription1)
                                .font(.system(size: 18, weight: .bold))
                            Text(TextLiteral.LookBook.makeNewCodiDescription2)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                        // MARK: Codi Board (Draggable Area)

                        /// 코디를 구성하는 드래그 보드 영역
                        /// - 선택된 상품 이미지가 자유롭게 배치됨
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(UIColor.systemGray6))
                                .frame(width: boardSize, height: boardSize)
                                .overlay(
                                    Text(TextLiteral.LookBook.selectItem)
                                        .foregroundColor(.gray)
                                        .opacity(viewModel.images.isEmpty ? 1 : 0)
                                )

                            // MARK: Draggable Images

                            /// 드래그 / 확대 / 회전 가능한 이미지들
                            ForEach($viewModel.images) { $image in
                                DraggableImageView(
                                    image: $image,
                                    imageHalfSize: imageHalfSize,
                                    minBound: minBound,
                                    maxBound: maxBound,
                                    viewModel: viewModel
                                )
                            }
                        }
                        .frame(width: boardSize, height: boardSize)
                        .padding(.horizontal, 20)

                        Spacer()
                    }

                    // MARK: Bottom Sheet (Product Selector)

                    /// 하단 고정형 상품 선택 바텀시트
                    /// - 검색 / 카테고리 필터
                    /// - 상품 선택 시 즉시 보드에 반영
                    VStack(spacing: 0) {

                        // MARK: Drag Indicator

                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 4)
                            .padding(.top, 8)
                            .padding(.bottom, 12)

                        // MARK: Product List

                        CustomProductBottomSheet(
                            searchText: $viewModel.searchText,
                            selectedCategory: $viewModel.selectedCategory,
                            selectedProducts: $viewModel.selectedProductIds,
                            products: viewModel.filteredProducts
                        ) { product in
                            viewModel.toggleProductSelection(product)
                        }
                    }
                    .frame(height: geometry.size.height * 0.42)
                    .background(Color.white)
                    .clipShape(
                        RoundedCorner(
                            radius: 20,
                            corners: [.topLeft, .topRight]
                        )
                    )
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 10,
                        x: 0,
                        y: -5
                    )
                }
                // MARK: Board Size Sync

                /// GeometryReader 기반으로 계산한 보드 크기를 ViewModel에 전달
                .onAppear {
                    viewModel.boardSize = boardSize
                }
            }
        }

        // MARK: - View Modifiers

        /// 기본 NavigationBar 숨김 (CustomNavigationBar 사용)
        .navigationBarHidden(true)

        /// 전체 화면 배경색 설정
        .background(Color.white.ignoresSafeArea())
    }
}
