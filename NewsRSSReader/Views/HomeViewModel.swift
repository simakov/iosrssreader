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
    @Published var categoryFeed: [NewsItem] = []
    @Published var isLoading = false
    @Published var isShowError = false
    @Published var firstNews: NewsItem?
    @Published var tab: Int = 0 {
        didSet {
            changeTab(to: tab)
        }
    }
    @Published var categories: [String] = []
    @Published var selectedCategory: String = "" {
        didSet {
            filteredNews()
        }
    }
    
    init(prewiew: Bool = false) {
        if prewiew {
            for _ in 0..<10 {
                rssFeed.append(NewsItem.sample)
            }
            firstNews = rssFeed.first
        } else {
            loadFeeds(source: .top7)
            preloadCategories()
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
    
    private func fillCategories(_ items: [NewsItem]) {
        var categoriesSet = Set<String>()
        items.forEach { item in
            if let categories = item.categories {
                categories.forEach { category in
                    categoriesSet.insert(category)
                }
            }
        }
        self.categories = categoriesSet.sorted()
    }
    
    private func preloadCategories() {
        LentaFeedService.shared.getFeed(source: .all) { (result) in
            switch result {
            case .success(let feed):
                DispatchQueue.main.async {
                    self.fillCategories(feed)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func filteredNews() {
        categoryFeed = []
        LentaFeedService.shared.getFeed(source: .all) { (result) in
            switch result {
            case .success(let feed):
                DispatchQueue.main.async {
                    self.categoryFeed = feed.filter { $0.categories?.contains(self.selectedCategory) == true }
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
