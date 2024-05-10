//
//  DetailNewsViewModel.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 10.05.2024.
//

import Foundation
import FeedKit

public struct NewsPage {
    let title: String
    let date: String
    let category: String
    let description: String
    let text: String
    let url: String
    init(from rss: RSSFeedItem) {
        title = rss.title ?? ""
        date = rss.publishedDate()
        if let categories = rss.categories {
            category = categories.first!.value!
        } else {
            category = ""
        }
        description = rss.description ?? ""
        url = rss.link ?? ""
        text = ""
    }
}

final class DetailNewsViewModel: ObservableObject {
    // MARK: - Inputs
    enum Inputs {
        case onLoad
        case onTapItem(urlString: String)
    }
    // MARK: - Outputs
    @Published private(set) var data: NewsPage
    @Published var isLoading = false
    @Published var isShowError = false
    
    init(_ data: NewsPage) {
        self.data = data
        self.load()
    }
    
    func load() {
        isLoading = true
    }
}
