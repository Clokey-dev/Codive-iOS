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
    @ObservedObject private var navigationRouter: NavigationRouter
    private let lookBookDIContainer: LookBookDIContainer
    
    // MARK: - Initializer
    init(viewModel: LookBookViewModel, lookBookDIContainer: LookBookDIContainer) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.navigationRouter = viewModel.navigationRouter
        self.lookBookDIContainer = lookBookDIContainer
    }
    
    var body: some View {
        // LookBook 전용 NavigationStack
        NavigationStack(path: $navigationRouter.path) {
            VStack(spacing: 0) {
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
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 100)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if viewModel.lookBookList.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 60))
                                .foregroundStyle(.gray)
                            
                            Text("아직 룩북이 없습니다")
                                .font(.headline)
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2),
                            spacing: 16
                        ) {
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
                                    } else {
                                        viewModel.navigateToSpecificLookBook(id: lookbook.id)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            // LookBook 관련 화면들만 처리
            .navigationDestination(for: AppDestination.self) { destination in
                lookBookDIContainer.lookBookViewFactory.makeView(for: destination)
            }
            .navigationBarHidden(true)
            .background(Color.white)
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
            .onAppear {
                if viewModel.lookBookList.isEmpty && !viewModel.isLoading {
                    viewModel.fetchLookBooks()
                }
            }
        }
    }
}

#Preview {
    let mockRouter = NavigationRouter()
    let mockDIContainer = LookBookDIContainer(navigationRouter: mockRouter)
    return LookBookView(
        viewModel: LookBookViewModel.preview,
        lookBookDIContainer: mockDIContainer
    )
}
