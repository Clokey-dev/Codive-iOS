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
                        Text(
                            "최근 검색어"
                        )
                        .font(Font.codive_title2)
                        .foregroundStyle(Color.Codive.grayscale1)
                        
                        Spacer()
                        
                        Text(
                            "전체 삭제"
                        )
                        .font(Font.codive_body3_medium)
                        .foregroundStyle(Color.Codive.grayscale3)
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
    }
}

#Preview {
    SearchView(viewModel: SearchViewModel.preview)
}
