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
                                viewModel.handleShowAll()
                            },
                            label: {
                                Text(TextLiteral.Search.showAll)
                                    .font(Font.codive_body3_medium)
                                    .foregroundStyle(Color.Codive.grayscale3)
                            }
                        )
                    }
                    .padding(.top, 32)

                    if viewModel.recentSearchTerms.isEmpty {
                        HStack {
                            Text(TextLiteral.Search.noTag)
                                .font(Font.codive_body2_medium)
                                .foregroundStyle(Color.Codive.grayscale3)
                            Spacer()
                        }
                        .padding(.top, 8)
                    } else {
                        VStack {
                            ForEach(viewModel.recentSearchTerms, id: \.self) { term in
                                RecentlySearchResultRow(
                                    type: .hashTag(title: term)
                                ) {
                                    viewModel.deleteTag(term: term)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.handleTagTap(term: term)
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
                                ) {
                                    viewModel.searchWithKeyword(news.subTitle)
                                }
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
            viewModel.loadRecentSearchTerms()
            viewModel.loadSearchRecommendation()
        }
    }
}
