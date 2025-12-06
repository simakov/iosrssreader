//
//  HomeViewModel.swift
//  NewsRSSReaderShared
//
//  Platform-agnostic ViewModel for iOS and watchOS
//

import SwiftUI

public final class HomeViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var rssFeed: [NewsItem] = []
    @Published public var categoryFeed: [NewsItem] = []
    @Published public var isLoading = false
    @Published public var isShowError = false
    @Published public var firstNews: NewsItem?
    @Published public var tab: Int = 0 {
        didSet {
            changeTab(to: tab)
        }
    }
    @Published public var categories: [String: String]
    @Published public var selectedCategory: String = "" {
        didSet {
            filteredNews(category: selectedCategory)
        }
    }

    public init(prewiew: Bool = false) {
        categories = LentaFeedService.shared.categories
        if prewiew {
            for _ in 0..<10 {
                rssFeed.append(NewsItem.sample)
            }
            firstNews = rssFeed.first
        } else {
            loadFeeds(source: .top7)
        }
    }

    public func changeTab(to source: Int) {
        self.rssFeed = []
        switch source {
        case 0:
            loadFeeds(source: .top7)
        case 1:
            loadFeeds(source: .last24)
        default:
            loadFeeds(source: .all)
        }
    }

    public func loadFeeds(source: LentaFeedService.Source) {
        LentaFeedService.shared.getFeed(source: source) { (result) in
            switch result {
            case .success(let feed):
                DispatchQueue.main.async {
                    self.rssFeed = Array(feed[1..<feed.count])
                    self.firstNews = feed.first
                }
            case .failure(let error):
                print(error)
                self.isShowError = true
            }
        }
    }

    private func filteredNews(category: String? = nil) {
        categoryFeed = []
        LentaFeedService.shared.getFeed(source: .all, category: category) { (result) in
            switch result {
            case .success(let feed):
                DispatchQueue.main.async {
                    self.categoryFeed = feed
                }
            case .failure(let error):
                print(error)
            }
        }

    }
}
