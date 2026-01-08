//
//  AddBeforeCodiView.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

struct AddBeforeCodiView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: AddBeforeCodiViewModel
    
    // MARK: - Initializer
    
    init(viewModel: AddBeforeCodiViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: Navigation Bar
            
            CustomNavigationBar(
                title: TextLiteral.LookBook.beforeCodi,
                onBack: viewModel.handleBackTap
            )
            
            // MARK: Content
            
            ScrollView {
                
                // MARK: Loading State
                
                if viewModel.isLoading {
                    ProgressView(TextLiteral.LookBook.loadingTitle)
                        .padding(.top, 100)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                } else if viewModel.beforeCoordinateDailyList.isEmpty {
                    Text(TextLiteral.LookBook.noBeforeCodice)
                        .foregroundColor(.gray)
                        .padding(.top, 100)
                } else {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: 16),
                            count: 2
                        ),
                        spacing: 16
                    ) {
                        ForEach(viewModel.beforeCoordinateDailyList) { lookbook in
                            BeforeCodiCard(
                                imageURL: lookbook.imageUrl,
                                date: lookbook.date,
                                isSelected: false
                            )
                            .onTapGesture {
                                viewModel.toggleSelection(id: lookbook.id)
                            }
                        }
                    }
                    .padding([.horizontal, .top], 16)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .onAppear {
            viewModel.fetchBeforeCoordinateDailyList()
        }
    }
}
