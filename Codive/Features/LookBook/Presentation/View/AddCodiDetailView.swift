//
//  AddCodiDetailView.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

struct AddCodiDetailView: View {
    @StateObject private var viewModel: AddCodiDetailViewModel
    @State private var isExpanded: Bool = false
    
    private let collapsedHeight: CGFloat = 250
    private var codiBoardView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemGray6))
            
            DraggableImageView(
                items: $viewModel.images,
                selectedImageID: viewModel.selectedImageID,
                onActivate: { id in
                    viewModel.selectImage(id: id)
                    viewModel.bringImageToFront(id: id)
                },
                onDeselect: {
                    viewModel.selectImage(id: nil)
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
            CustomNavigationBar(
                title: TextLiteral.LookBook.makeNewCodi,
                onBack: viewModel.handleBackTap,
                rightButton: .text(
                    title: TextLiteral.Common.complete,
                    isEnabled: !viewModel.selectedProductIds.isEmpty
                ) {
                    Task {
                        viewModel.selectImage(id: nil)
                        try? await Task.sleep(nanoseconds: 200_000_000)
                        await viewModel.captureBoard(view: codiBoardView)
                        await viewModel.handleComplete()
                    }
                }
            )
            .padding(.horizontal, 15)
            
            GeometryReader { geometry in
                let boardSize = geometry.size.width - 40
                
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
        .toolbar(.hidden, for: .navigationBar)
        .enableSwipeBack()
        .background(Color.white.ignoresSafeArea())
    }
}

private extension AddCodiDetailView {
    
    @ViewBuilder
    func bottomSheet(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
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
