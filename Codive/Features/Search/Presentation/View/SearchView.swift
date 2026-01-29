//
//  SearchView.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import SwiftUI

struct SearchView: View {
    // MARK: - Properties
    @StateObject private var viewModel: SearchViewModel
    @State private var searchText: String = ""
    
    // MARK: - Initializer
    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            CustomSearchBar(
                text: $searchText,
                type: .withBackButton {
                    viewModel.handleBackTap()
                }
            ) {
                viewModel.executeSearch(query: searchText)
                hideKeyboard()
            }
            .onSubmit {
                viewModel.executeSearch(query: searchText)
            }
            
            ScrollView {
                VStack {
                    // MARK: - Recent Search Tags Section
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
                            Text(TextLiteral.Search.noTag)
                                .font(Font.codive_body2_medium)
                                .foregroundStyle(Color.Codive.grayscale3)
                            Spacer()
                        }
                        .padding(.top, 8)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(viewModel.recentSearchTags) { tag in
                                    Button {
                                        self.searchText = tag.text
                                        viewModel.handleTagTap(tag: tag)
                                    } label: {
                                        SearchTagView(text: tag.text) {
                                            viewModel.deleteTag(tag: tag)
                                        }
                                        .padding(.vertical, 2)
                                        .padding(.horizontal, 2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    
                    // MARK: - Recommended News Section
                    HStack {
                        Text(
                            "\(viewModel.username)\(TextLiteral.Search.recommendedNewsTitle)"
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
                                    title: news.title,
                                    subTitle: news.subTitle
                                )
                            }
                        }
                    }.padding(.top, 8)
                }
                .padding(.bottom, 20)
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            Color.white
                .ignoresSafeArea(.all)
                .onTapGesture { 
                    hideKeyboard()
                }
        )
        .padding(.horizontal, 20)
        // MARK: - Data Loading Trigger
        .onAppear {
            viewModel.loadData()
            viewModel.loadSearchRecommendation()
        }
        // MARK: - Alert
        .alert(
            TextLiteral.Search.alertTitle,
            isPresented: $viewModel.showingDeleteAlert
        ) {
            Button(TextLiteral.Search.alertDelete, role: .destructive) {
                viewModel.executeDeleteAll()
            }
            Button(TextLiteral.Search.alertCancel, role: .cancel) {}
        } message: {
            Text(TextLiteral.Search.noRestore)
        }
    }
}
