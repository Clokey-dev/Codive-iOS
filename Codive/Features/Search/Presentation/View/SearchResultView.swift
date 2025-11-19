//
//  SearchResultView.swift
//  Codive
//
//  Created by 한금준 on 11/19/25.
//

import SwiftUI

struct SearchResultView: View {
    @StateObject private var viewModel: SearchResultViewModel
    @State private var searchText: String = ""
    
    init(viewModel: SearchResultViewModel) {
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
                        Text("총 6개")
                            .font(Font.codive_body2_medium)
                            .foregroundStyle(Color.Codive.grayscale3)
                        Spacer()
                        
                        Text("전체")
                            .font(Font.codive_body2_medium)
                            .foregroundStyle(Color.Codive.grayscale3)
                    }
                    .padding(.top, 18)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 11) {
                        PostCard(
                            postImageUrl: "https://picsum.photos/id/1018/162/216",
                            profileImageUrl: "httpsum.photos/id/237/28/28",
                            nickname: "닉네임"
                        )
                        PostCard(
                            postImageUrl: "httpsum.photos/id/1019/162/216",
                            profileImageUrl: nil,
                            nickname: "긴닉네임테스트"
                        )
                        PostCard(
                            postImageUrl: "https://picsum.photos/id/1018/162/216",
                            profileImageUrl: "httpsum.photos/id/237/28/28",
                            nickname: "닉네임"
                        )
                        PostCard(
                            postImageUrl: "httpsum.photos/id/1019/162/216",
                            profileImageUrl: nil,
                            nickname: "긴닉네임테스트"
                        )
                        PostCard(
                            postImageUrl: "https://picsum.photos/id/1018/162/216",
                            profileImageUrl: "httpsum.photos/id/237/28/28",
                            nickname: "닉네임"
                        )
                        PostCard(
                            postImageUrl: "httpsum.photos/id/1019/162/216",
                            profileImageUrl: nil,
                            nickname: "긴닉네임테스트"
                        )
                        PostCard(
                            postImageUrl: "https://picsum.photos/id/1018/162/216",
                            profileImageUrl: "httpsum.photos/id/237/28/28",
                            nickname: "닉네임"
                        )
                        PostCard(
                            postImageUrl: "httpsum.photos/id/1019/162/216",
                            profileImageUrl: nil,
                            nickname: "긴닉네임테스트"
                        )
                    }
                    .padding(.top, 18)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea(.all))
        .padding(.horizontal, 20)
    }
}

#Preview {
    SearchResultView(viewModel: SearchResultViewModel.preview)
}
