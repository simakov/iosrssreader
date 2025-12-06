//
//  WatchHomeView.swift
//  NewsRSSReaderWatch
//
//  Main home view with categories and news list
//

import SwiftUI
import NewsRSSReaderShared

struct WatchHomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        List {
            // Feed
            Section("Лента") {
                NavigationLink("Главное", destination: WatchFeedView(
                    source: .top7,
                    feedName: "Главное",
                    viewModel: viewModel
                ))
                NavigationLink("Последнее", destination: WatchFeedView(
                    source: .last24,
                    feedName: "Последнее",
                    viewModel: viewModel
                ))
                NavigationLink("Все новости", destination: WatchFeedView(
                    source: .all,
                    feedName: "Все новости",
                    viewModel: viewModel
                ))
            }

            // Categories
            Section("Категории") {
                ForEach(Array(viewModel.categories.keys.sorted()), id: \.self) { key in
                    if let name = viewModel.categories[key] {
                        NavigationLink(name, destination: WatchCategoryView(
                            category: key,
                            categoryName: name,
                            viewModel: viewModel
                        ))
                    }
                }
            }
        }
        .navigationTitle("Лента.ру")
    }
}

#Preview {
    WatchHomeView(viewModel: HomeViewModel(prewiew: true))
}
