//
//  AddCodiDetailView.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

struct AddCodiDetailView: View {
    
    // MARK: - State Object
    
    @StateObject private var viewModel: AddCodiDetailViewModel
    @State private var isExpanded: Bool = false
    
    private let collapsedHeight: CGFloat = 250
    
    // 캡처할 대상 뷰를 별도로 정의
    private var codiBoardView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemGray6))
            
            DraggableImageView(
                items: $viewModel.images,
                onActivate: { id in
                    viewModel.bringImageToFront(id: id)
                }
            )
        }
        .frame(width: viewModel.boardSize, height: viewModel.boardSize)
        .clipped()
    }
    
    // MARK: - Initializer
    
    init(viewModel: AddCodiDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: Top Navigation Bar
            
            CustomNavigationBar(
                title: TextLiteral.LookBook.makeNewCodi,
                onBack: viewModel.handleBackTap,
                rightButton: .text(
                    title: TextLiteral.Common.complete,
                    isEnabled: !viewModel.selectedProductIds.isEmpty,
                    action: {
                        // 버튼 클릭 시 비동기 Task 시작
                        Task {
                            // 0.2초 대기 (이미지가 렌더링될 시간 확보)
                            try? await Task.sleep(nanoseconds: 200_000_000)
                            
                            // 캡처 및 완료 처리
                            await viewModel.captureBoard(view: codiBoardView)
                            await viewModel.handleComplete()
                        }
                    }
                )
            )
            .padding(.horizontal, 15)
            
            // MARK: Geometry Reader (Layout Calculation)
            
            GeometryReader { geometry in
                let boardSize = geometry.size.width - 40
                let imageHalfSize: CGFloat = 40
                
                // MARK: Main Content ZStack
                
                ZStack(alignment: .bottom) {
                    VStack(spacing: 20) {
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
                        
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(Color(UIColor.systemGray6))
//                                .frame(width: boardSize, height: boardSize)
//                                .overlay(
//                                    Text(TextLiteral.LookBook.selectItem)
//                                        .foregroundColor(.gray)
//                                        .opacity(viewModel.images.isEmpty ? 1 : 0)
//                                )
//                            
//                            // MARK: DraggableImageContainerView 사용
//                            
//                            DraggableImageView(
//                                items: $viewModel.images,
//                                onActivate: { id in
//                                    viewModel.bringImageToFront(id: id)
//                                }
//                            )
//                        }
//                        .frame(width: boardSize, height: boardSize)
//                        .padding(.horizontal, 20)
                        
                        // MARK: Codi Board (Draggable Area)
                        codiBoardView
                            .cornerRadius(15)
                            .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    
                    bottomSheet(geometry: geometry)
                        .ignoresSafeArea(.all, edges: .bottom)
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
    
    @ViewBuilder
    func bottomSheet(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Handle Bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.Codive.grayscale5)
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .onTapGesture {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }
            
            CustomProductBottomSheet(
                searchText: $viewModel.searchText,
                selectedCategory: $viewModel.selectedCategory,
                selectedProducts: $viewModel.selectedProductIds,
                products: viewModel.clothItems
            ) { product in
                viewModel.toggleProductSelection(product)
            }
        }
        .frame(
            width: geometry.size.width,
            height: isExpanded ? geometry.size.height * 0.7 : collapsedHeight
        )
        .background(Color.white)
        .customCornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        .gesture(
            DragGesture()
                .onEnded { value in
                    let dragDistance = value.translation.height
                    
                    withAnimation(.spring()) {
                        if dragDistance < -50 {
                            isExpanded = true
                        } else if dragDistance > 50 {
                            isExpanded = false
                        }
                    }
                }
        )
    }
}
