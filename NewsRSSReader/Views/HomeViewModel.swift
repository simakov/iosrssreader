//
//  HomeViewModel.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 03.05.2024.
//


import SwiftUI
import FeedKit
import UIKit

final class HomeViewModel: ObservableObject {
    // MARK: - Inputs
    enum Inputs {
        case onLoad
        case onTapItem(urlString: String)
    }
    
    // MARK: - Outputs
    @Published private(set) var rssFeed: [RSSFeedItem] = []
    private var allFeed: [RSSFeedItem] = []
    @Published var isLoading = false
    @Published var isShowError = false
    @Published var firstNews: RSSFeedItem?
    var lastIndex = 0
    var itemsOnPage = 10
    init(_ url: String) {
        isLoading = true
        self.load(url)
    }

    func load(_ url: String) {
        let feedURL = URL(string: url)!
        let parser = FeedParser(URL: feedURL)
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let feed):
                    switch feed {
                    case let .atom(_):
                        self.rssFeed = []
                        break
                    case .json(_):       // JSON Feed Model
                        self.rssFeed = []
                    case let .rss(feed):        // Really Simple Syndication Feed Model
                        if let entries = feed.items {
                            self.allFeed = entries
                            self.firstNews = entries.first
                            self.addMore()
                            self.isShowError = false
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                    self.isShowError = true
                }
                self.isLoading = false
            }
        }
    }
    public func addMore()
    {
        if lastIndex + itemsOnPage > allFeed.endIndex {
            self.lastIndex = allFeed.endIndex
        } else {
            self.lastIndex += itemsOnPage
        }
        self.rssFeed = Array(allFeed[..<self.lastIndex])
    }
}

extension RSSFeedItem: Identifiable {
    //public let id = UUID()
            
    func publishedDate() -> String {
        guard let date = pubDate else { return "" }
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        let fullDateFormatter = DateFormatter()
        
        // Set the date format for the current day (time only)
        dateFormatter.dateFormat = "HH:mm"
        
        // Set the date format for all other days (date and time)
        let fullDateFormat = "d.MM HH:mm"
        fullDateFormatter.dateFormat = fullDateFormat
        
        let calendar = Calendar.current
        
        // Comparing dates to determine if the date is the current day
        let components1 = calendar.dateComponents([.day, .month, .year], from: date)
        let components2 = calendar.dateComponents([.day, .month, .year], from: currentDate)
        
        if components1.day == components2.day && components1.month == components2.month && components1.year == components2.year {
            // If the date is the current day, we return only the time
            return dateFormatter.string(from: date)
        } else {
            // If the date is not the current day, return the date and time
            return fullDateFormatter.string(from: date)
        }
    }
}
