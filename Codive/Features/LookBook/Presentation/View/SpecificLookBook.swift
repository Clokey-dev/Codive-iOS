//
//  SpecificLookBook.swift
//  Codive
//
//  Created by 한금준 on 11/27/25.
//

import SwiftUI

struct SpecificLookBook: View {
    
    // MARK: - State Object & Local State
    
    @StateObject private var viewModel: SpecificLookBookViewModel
    @State private var likedCodyIds: Set<Int> = []
    
    // MARK: - Initializer
    
    init(viewModel: SpecificLookBookViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // MARK: Top Navigation Bar
                
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
                            { viewModel.handleDeleteAction() }
                        ]
                    )
                )
                .zIndex(10)
                .padding(.leading, 15)
                
                // MARK: Content Area
                
                ScrollView {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: 16),
                            count: 2
                        ),
                        spacing: 16
                    ) {
                        ForEach(viewModel.lookBookList) { lookbook in
                            LookBookCard(
                                imageURL: lookbook.imageURL,
                                cardTitle: lookbook.cardTitle,
                                iconType: viewModel.isEditing ? .checkmark : .heart,
                                isSelected: viewModel.isEditing
                                ? viewModel.selectedCodiIds.contains(lookbook.id)
                                : likedCodyIds.contains(lookbook.id)
                            ) {
                                if viewModel.isEditing {
                                    viewModel.toggleSelection(id: lookbook.id)
                                } else {
                                    handleLikeTap(codyId: lookbook.id)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
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
                .onAppear {
                    if viewModel.lookBookList.isEmpty {
                        viewModel.fetchCodis()
                    }
                }
            }
            
            // MARK: Loading Overlay
            
            if viewModel.isLoading {
                LoadingView(backgroundStyle: .white)
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .alert(
            TextLiteral.LookBook.alertDeleteTitle,
            isPresented: $viewModel.isShowingDeleteAlert
        ) {
            Button(TextLiteral.Common.delete, role: .destructive) {
                viewModel.beginDelete()
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
