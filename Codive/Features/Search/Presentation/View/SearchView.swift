//
//  SearchView.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @State private var searchText: String = ""
    
    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            CustomSearchBar(
                text: $searchText,
                type: .withBackButton {
                    viewModel.handleBackTap()
                }
            )
            
            ScrollView {
                VStack {
                    HStack {
                        Text(TextLiteral.Search.recentSearch)
                        .font(Font.codive_title2)
                        .foregroundStyle(Color.Codive.grayscale1)
                        
                        Spacer()
                        
                        Button(
                            action: {
                                viewModel.handleDeleteAll()
                            },
                            label: {
                                Text(TextLiteral.Search.deleteAll)
                                    .font(Font.codive_body3_medium)
                                    .foregroundStyle(Color.Codive.grayscale3)
                            }
                        )
                    }
                    .padding(.top, 32)
                    
                    HStack {
                        Text(
                            "00님을 위한 추천 소식"
                        )
                        .font(Font.codive_title2)
                        .foregroundStyle(Color.Codive.grayscale1)
                        
                        Spacer()
                    }
                    .padding(.top, 32)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.recommendedNews) { news in
                                NewsCard(
                                    imageUrl: news.imageUrl,
                                    title: news.title
                                )
                            }
                        }
                    }.padding(.top, 8)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea(.all))
        .padding(.horizontal, 20)
        .alert(
            "최근 검색어를 모두 삭제하시겠습니까?", // 제목
            isPresented: $viewModel.showingDeleteAlert // 표시 조건
        ) {
            // "삭제" 버튼 (빨간색으로 표시하기 위해 .destructive 사용)
            Button("삭제", role: .destructive) {
                viewModel.executeDeleteAll()
            }
            // "취소" 버튼 (기본 역할)
            Button("취소", role: .cancel) {
                // 아무 작업도 하지 않음
            }
        } message: {
            Text("한 번 삭제된 기록은 복구할 수 없습니다") // 메시지
        }
    }
}

#Preview {
    SearchView(viewModel: SearchViewModel.preview)
}
