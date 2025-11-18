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
                    
                    if viewModel.recentSearchTags.isEmpty {
                        HStack {
                            Text("최근 검색어가 없습니다.")
                                .font(Font.codive_body2_medium)
                                .foregroundStyle(Color.Codive.grayscale3)
                            Spacer()
                        }
                        .padding(.top, 8)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.recentSearchTags) { tag in
                                    SearchTagView(text: tag.text) {
                                        viewModel.deleteTag(tag: tag)
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    
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
            "최근 검색어를 모두 삭제하시겠습니까?",
            isPresented: $viewModel.showingDeleteAlert
        ) {
            Button("삭제", role: .destructive) {
                viewModel.executeDeleteAll()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("한 번 삭제된 기록은 복구할 수 없습니다")
        }
    }
}

#Preview {
    SearchView(viewModel: SearchViewModel.preview)
}
