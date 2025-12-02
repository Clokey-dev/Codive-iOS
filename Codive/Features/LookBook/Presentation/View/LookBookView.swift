// LookBookView.swift
//
//  LookBookView.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import SwiftUI

struct LookBookView: View {
    // MARK: - Properties
    @StateObject private var viewModel: LookBookViewModel
    
    // MARK: - Initializer
    init(viewModel: LookBookViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                title: TextLiteral.LookBook.title,
                onBack: viewModel.handleBackTap,
                rightButton: viewModel.isEditing ?
                    .text(
                        title: TextLiteral.Common.delete,
                        isEnabled: !viewModel.selectedLookBookIds.isEmpty,
                        action: viewModel.handleCompleteAction
                    ) :
                    .overflow(
                        menuType: .lookbook,
                        menuActions: [
                            { print("룩북 만들기 tapped") },
                            viewModel.handleDeleteAction
                        ]
                    )
            )
            .zIndex(10)
            .padding(.leading, 15)
            
            ScrollView {
                if viewModel.isLoading {
                    ProgressView(TextLiteral.LookBook.loadingTitle)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        ForEach(viewModel.lookBookList) { lookbook in
                            LookBookCard(
                                imageURL: lookbook.imageURL,
                                cardTitle: lookbook.cardTitle,
                                iconType: viewModel.isEditing ? .checkmark : .none,
                                isSelected: viewModel.selectedLookBookIds.contains(lookbook.id)
                            )
                            .onTapGesture {
                                if viewModel.isEditing {
                                    viewModel.toggleSelection(id: lookbook.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .onAppear {
                if viewModel.lookBookList.isEmpty {
                    viewModel.fetchLookBooks()
                }
            }
        }
        .navigationBarHidden(true)
        .background(alignment: .center) {
            Color.white
        }

        .alert(
            TextLiteral.LookBook.alertDeleteTitle,
            isPresented: $viewModel.isShowingDeleteAlert,
            actions: {
                Button(TextLiteral.Common.delete, role: .destructive) {
                    viewModel.confirmDelete()
                }
                Button(TextLiteral.Common.cancel, role: .cancel) {
                }
            },
            message: {
                Text(TextLiteral.LookBook.alertDeleteSubTitle)
            }
        )
    }
}

#Preview {
    LookBookView(viewModel: LookBookViewModel.preview)
}
