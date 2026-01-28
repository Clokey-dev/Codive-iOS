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
            navigationBar
            
            contentScrollView
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .onAppear {
            viewModel.fetchBeforeCoordinateDailyList()
        }
    }
}

// MARK: - View Components

private extension AddBeforeCodiView {
    
    /// 상단 네비게이션 바
    var navigationBar: some View {
        CustomNavigationBar(
            title: TextLiteral.LookBook.beforeCodi,
            onBack: viewModel.handleBackTap
        )
    }
    
    /// 메인 컨텐츠 스크롤 영역
    var contentScrollView: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(message: error)
                } else if viewModel.beforeCoordinateDailyList.isEmpty {
                    emptyStateView
                } else {
                    beforeCodiGrid
                }
            }
        }
    }
    
    /// 이전 코디 목록 그리드
    var beforeCodiGrid: some View {
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
                    viewModel.toggleSelection(id: Int(lookbook.id))
                }
            }
        }
        .padding([.horizontal, .top], 16)
    }
}

// MARK: - Subviews (Status Views)

private extension AddBeforeCodiView {
    
    /// 로딩 중 표시되는 뷰
    var loadingView: some View {
        ProgressView(TextLiteral.LookBook.loadingTitle)
            .padding(.top, 100)
    }
    
    /// 에러 발생 시 표시되는 뷰
    func errorView(message: String) -> some View {
        Text(message)
            .foregroundStyle(.red)
            .padding()
            .padding(.top, 100)
    }
    
    /// 데이터가 없을 때 표시되는 빈 화면 뷰
    var emptyStateView: some View {
        Text(TextLiteral.LookBook.noBeforeCodice)
            .foregroundColor(.gray)
            .padding(.top, 100)
    }
}
