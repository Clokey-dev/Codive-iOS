//
//  FeedView.swift
//  Codive
//
//  Created by 황상환 on 9/24/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel: FeedViewModel

    init(viewModel: FeedViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.feeds.isEmpty {
                ProgressView("피드 로딩 중...")
            } else if let errorMessage = viewModel.errorMessage {
                Text("에러: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                List(viewModel.feeds) { feed in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Feed #\(feed.id)")
                            .font(.headline)
                        if let content = feed.content {
                            Text(content)
                                .font(.body)
                        }
                        if let author = feed.author {
                            Text("by \(author.nickname)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .task {
            await viewModel.loadFeeds()
        }
    }
}

#Preview {
    let container = FeedDIContainer()
    return FeedView(viewModel: container.makeFeedViewModel())
}
