//
//  WatchCategoryView.swift
//  NewsRSSReaderWatch
//
//  Category news feed view
//

import SwiftUI
import NewsRSSReaderShared

struct WatchCategoryView: View {
    let category: String
    let categoryName: String
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        List {
            if viewModel.categoryFeed.isEmpty {
                ForEach(0..<3, id: \.self) { _ in
                    WatchNewsRowPlaceholder()
                }
            } else {
                ForEach(viewModel.categoryFeed) { item in
                    NavigationLink(destination: WatchArticleDetailView(newsItem: item)) {
                        WatchNewsRow(item: item)
                    }
                }
            }
        }
        .navigationTitle(categoryName)
        .onAppear {
            viewModel.selectedCategory = category
        }
    }
}

#Preview {
    WatchCategoryView(
        category: "russia",
        categoryName: "Россия",
        viewModel: HomeViewModel(prewiew: true)
    )
}
