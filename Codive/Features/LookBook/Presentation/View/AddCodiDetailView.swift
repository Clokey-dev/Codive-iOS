//
//  AddCodiDetailView.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

struct AddCodiDetailView: View {
    @StateObject private var viewModel: AddCodiDetailViewModel
    
    init(viewModel: AddCodiDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단바
            CustomNavigationBar(
                title: "새 코디 만들기",
                onBack: viewModel.handleBackTap,
                rightButton: .text(
                    title: "완료",
                    isEnabled: !viewModel.selectedProductIds.isEmpty,
                    action: viewModel.handleComplete
                )
            )
            .padding(.horizontal, 15)
            
            GeometryReader { geometry in
                let boardSize = geometry.size.width - 40
                let imageHalfSize: CGFloat = 40
                let minBound = imageHalfSize
                let maxBound = boardSize - imageHalfSize
                
                ZStack(alignment: .bottom) {
                    // 배경 콘텐츠
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("옷을 선택해 새로운 코디를 만들어보세요!")
                                .font(.system(size: 18, weight: .bold))
                            Text("아이템은 최대 10개까지 등록할 수 있어요")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // 코디 제작 영역 (DraggableImageView로 대체)
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(UIColor.systemGray6))
                                .frame(width: boardSize, height: boardSize)
                                .overlay(
                                    Text("아이템을 선택해 주세요")
                                        .foregroundColor(.gray)
                                        .opacity(viewModel.images.isEmpty ? 1 : 0)
                                )
                            
                            // 드래그 가능한 이미지들
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
                    
                    // 하단 바텀시트 (고정형)
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 4)
                            .padding(.top, 8)
                            .padding(.bottom, 12)
                        
                        CustomProductBottomSheet(
                            searchText: $viewModel.searchText,
                            selectedCategory: $viewModel.selectedCategory,
                            selectedProducts: $viewModel.selectedProductIds,
                            products: viewModel.filteredProducts,
                            onProductTap: { product in
                                viewModel.toggleProductSelection(product)
                            }
                        )
                    }
                    .frame(height: geometry.size.height * 0.42)
                    .background(Color.white)
                    .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
                .onAppear {
                        viewModel.boardSize = boardSize
                    }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea())
    }
}
