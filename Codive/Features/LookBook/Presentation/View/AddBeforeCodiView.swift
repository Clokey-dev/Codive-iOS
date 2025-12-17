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
    @State private var selectedCodyIds: Set<Int> = []
    
    // MARK: - Initializer
    init(viewModel: AddBeforeCodiViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) { // spacing을 0으로 설정하여 상단바와 밀착
            CustomNavigationBar(
                title: "이전 코디",
                onBack: viewModel.handleBackTap
            )
            
            ScrollView {
                if viewModel.isLoading {
                    ProgressView(TextLiteral.LookBook.loadingTitle)
                        .padding(.top, 100)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                } else if viewModel.lookBookList.isEmpty {
                    Text("해당 룩북에 코디가 없습니다.")
                        .foregroundColor(.gray)
                        .padding(.top, 100)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        ForEach(viewModel.lookBookList) { lookbook in
                            BeforeCodiCard(
                                imageURL: lookbook.imageURL,
                                date: lookbook.date,
                                isSelected: viewModel.selectedLookBookIds.contains(lookbook.id)
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
            viewModel.fetchLookBooks()
        }
    }
}

#Preview {
    AddBeforeCodiView(viewModel: AddBeforeCodiViewModel.preview)
}
