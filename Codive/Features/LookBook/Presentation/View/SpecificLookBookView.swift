//
//  SpecificLookBookView.swift
//  Codive
//
//  Created by 한금준 on 11/27/25.
//

import SwiftUI

struct SpecificLookBookView: View {
    
    // MARK: - State Object & Local State
    
    @StateObject private var viewModel: SpecificLookBookViewModel
    
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
                        ForEach(viewModel.specificLookBookCodiList) { codi in
                            LookBookCard(
                                imageURL: codi.imageUrl,
                                cardTitle: codi.coordinateName,
                                iconType: viewModel.isEditing ? .checkmark : .heart,
                                isSelected: viewModel.isEditing
                                ? viewModel.selectedCodiIds.contains(codi.id)
                                : viewModel.likedCodiIds.contains(codi.id)
                            ) {
                                if viewModel.isEditing {
                                    viewModel.toggleSelection(id: codi.id)
                                } else {
                                    viewModel.toggleLike(codyId: codi.id)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if viewModel.isEditing {
                                    viewModel.toggleSelection(id: codi.id)
                                } else {
                                    viewModel.navigateToCodiDetail(codiId: codi.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                .onAppear {
                    if viewModel.specificLookBookCodiList.isEmpty {
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
}
