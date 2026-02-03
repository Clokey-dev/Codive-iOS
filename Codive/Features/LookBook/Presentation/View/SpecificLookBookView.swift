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
                CustomNavigationBar(
                    title: $viewModel.name,
                    isEditingMode: viewModel.isEditing,
                    onBack: viewModel.handleBackTap,
                    onBeginEditTitle: viewModel.beginEditTitle,
                    onConfirmEditTitle: viewModel.confirmEditTitle,
                    onCancelEditTitle: viewModel.cancelEditTitle,
                    rightButton: viewModel.isEditing
                    ? .text(
                        title: TextLiteral.Common.delete,
                        isEnabled: viewModel.selectedCodiId != nil,
                        action: viewModel.handleCompleteAction
                    )
                    : .overflow(
                        menuType: .feed,
                        menuActions: [
                            { viewModel.navigateToAddCodi() },
                            { viewModel.handleEditAction() }
                        ]
                    )
                )
                .zIndex(10)
                .padding(.leading, 15)
                
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
                                ? viewModel.selectedCodiId == codi.id
                                : viewModel.likedCodiId == codi.id
                            ) {
                                if viewModel.isEditing {
                                    viewModel.toggleSelection(id: codi.id)
                                } else {
                                    viewModel.toggleLike(coordinateId: codi.id)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if viewModel.isEditing {
                                    viewModel.toggleSelection(id: codi.id)
                                } else {
                                    viewModel.navigateToCodiDetail(codiId: Int(codi.id))
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
