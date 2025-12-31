//
//  SearchResultView.swift
//  Codive
//
//  Created by 한금준 on 11/19/25.
//

import SwiftUI

struct SearchResultView: View {
    // MARK: - Properties
    @StateObject private var viewModel: SearchResultViewModel
    @State private var selectedSegment: SearchResultSegment = .account
    
    // MARK: - Computed Properties
    private var sortOptionsString: [String] {
        viewModel.sortOptions.map { $0.displayName }
    }
    
    // MARK: - Initializer
    init(viewModel: SearchResultViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            CustomSearchBar(
                text: $viewModel.searchBarText,
                type: .withBackButton {
                    viewModel.handleBackTap()
                }
            ) {
                viewModel.executeNewSearch(query: viewModel.searchBarText)
                hideKeyboard()
            }
            .padding(.horizontal, 20)
            .zIndex(1)
            .onSubmit {
                viewModel.executeNewSearch(query: viewModel.searchBarText)
            }
            
            SearchResultSegmentControl(selectedSegment: $selectedSegment)
                .padding(.top, 8)
            
            ScrollView {
                // MARK: - Account Result List
                if selectedSegment == .account {
                    VStack(spacing: 0) {
                        ForEach(viewModel.users, id: \.userId) { user in
                            CustomUserRow(
                                user: user,
                                buttonStyle: .none
                            ) {
                                // 버튼 동작
                            }
                        }
                    }
                    .padding(.top, 18)
                } else {
                    // MARK: - Hashtag Result Grid
                    HashtagView(viewModel: viewModel)
                        .padding(.horizontal, 20)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationBarHidden(true)
        .background(
            Color.white
                .ignoresSafeArea(.all)
                .onTapGesture { // 3. 배경 터치 시 키보드 내림
                    hideKeyboard()
                }
        )
        // MARK: - Data Loading Trigger
        .onAppear {
            viewModel.loadInitialData()
        }
    }
}
