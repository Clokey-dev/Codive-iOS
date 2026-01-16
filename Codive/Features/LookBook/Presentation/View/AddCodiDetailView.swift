//
//  AddCodiDetailView.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

struct AddCodiDetailView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: AddCodiDetailViewModel
    
    // MARK: - Initializer
    init(viewModel: AddCodiDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            GeometryReader { geometry in
                let boardSize = geometry.size.width - 40
                
                ZStack(alignment: .bottom) {
                    mainContent(boardSize: boardSize)
                    
                    productSelectorSheet(height: geometry.size.height * 0.42)
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

// MARK: - View Components
private extension AddCodiDetailView {
    
    /// 상단 네비게이션 바
    var navigationBar: some View {
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
    }
    
    /// 설명 텍스트와 코디판을 포함한 메인 컨텐츠
    func mainContent(boardSize: CGFloat) -> some View {
        VStack(spacing: 20) {
            headerDescription
            
            drawingBoard(size: boardSize)
            
            Spacer()
        }
        .padding(.top, 10)
    }
    
    /// 상단 설명 텍스트 영역
    var headerDescription: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(TextLiteral.LookBook.makeNewCodiDescription1)
                .font(.system(size: 18, weight: .bold))
            Text(TextLiteral.LookBook.makeNewCodiDescription2)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    /// 드래그 가능한 이미지들이 배치되는 코디판
    func drawingBoard(size: CGFloat) -> some View {
        let imageHalfSize: CGFloat = 40
        let minBound = imageHalfSize
        let maxBound = size - imageHalfSize
        
        return ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemGray6))
                .frame(width: size, height: size)
                .overlay(
                    Text(TextLiteral.LookBook.selectItem)
                        .foregroundColor(.gray)
                        .opacity(viewModel.images.isEmpty ? 1 : 0)
                )
            
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
        .frame(width: size, height: size)
        .padding(.horizontal, 20)
    }
    
    /// 하단 제품 선택 바텀시트
    func productSelectorSheet(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            dragIndicator
            
            CustomProductBottomSheet(
                searchText: $viewModel.searchText,
                selectedCategory: $viewModel.selectedCategory,
                selectedProducts: $viewModel.selectedProductIds,
                products: viewModel.filteredProducts
            ) { product in
                viewModel.toggleProductSelection(product)
            }
        }
        .frame(height: height)
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    /// 바텀시트 상단 드래그 인디케이터
    var dragIndicator: some View {
        Capsule()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 40, height: 4)
            .padding(.top, 8)
            .padding(.bottom, 12)
    }
}
