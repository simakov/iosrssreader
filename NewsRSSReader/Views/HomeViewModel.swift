//
//  HomeViewModel.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 03.05.2024.
//


import SwiftUI

final class HomeViewModel: ObservableObject {
    // MARK: - Outputs
    @Published private(set) var rssFeed: [NewsItem] = []
    @Published var isLoading = false
    @Published var isShowError = false
    @Published var firstNews: NewsItem?
    @Published var tab: Int = 0 {
        didSet {
            changeTab(to: tab)
        }
    }
    
    var allFeed: [NewsItem] = []
    var rssTopFeed: [NewsItem] = []
    var rssLast24Feed: [NewsItem] = []
    var lastIndex = 0
    var itemsOnPage = 10

    init(prewiew: Bool = false) {
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
        lastIndex = source
    }
    
    public func loadFeeds(source: LentaFeedService.Source) {
        LentaFeedService.shared.getFeed(source: source) { (result) in
            switch result {
            case .success(let feed):
                self.rssFeed = Array(feed[1..<feed.count])
                self.firstNews = feed.first
            case .failure(let error):
                print(error)
                self.isShowError = true
            }
        }
    }
}
