//
//  WatchFeedView.swift
//  NewsRSSReaderWatch
//
//  Feed view for specific feed source (top7, last24, all)
//

import SwiftUI
import NewsRSSReaderShared

struct WatchFeedView: View {
    let source: LentaFeedService.Source
    let feedName: String
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        List {
            if viewModel.rssFeed.isEmpty {
                ForEach(0..<3, id: \.self) { _ in
                    WatchNewsRowPlaceholder()
                }
            } else {
                ForEach(viewModel.rssFeed) { item in
                    NavigationLink(destination: WatchArticleDetailView(newsItem: item)) {
                        WatchNewsRow(item: item)
                    }
                }
            }
        }
        .navigationTitle(feedName)
        .onAppear {
            viewModel.loadFeeds(source: source)
        }
    }
}

#Preview {
    WatchFeedView(
        source: .top7,
        feedName: "Главное",
        viewModel: HomeViewModel(prewiew: true)
    )
}
