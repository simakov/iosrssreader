//
//  NewsItem.swift
//  NewsRSSReaderShared
//
//  Platform-agnostic model for iOS and watchOS
//

import Foundation
import FeedKit

public struct NewsItem: Identifiable, Codable {
    public var id: UUID = UUID()
    public var title: String?
    public var summary: String?
    public var authors: [String]?
    public var link: String?
    public var updated: Date?
    public var categories: [String]?
    public var content: String?
    public var published: Date?
    public var source: String?
    public var rights: String?
    public var image: String?

    public init(from entry: AtomFeedEntry) {
        self.title = entry.title
        self.summary = entry.summary?.value
        self.authors = entry.authors?.compactMap { $0.name }
        self.link = entry.links?.first?.attributes?.href
        self.updated = entry.updated
        self.categories = entry.categories?.compactMap { $0.attributes?.label }
        self.content = entry.content?.value
        self.published = entry.published
        self.source = entry.source?.title
        self.rights = entry.rights
        self.image = entry.media?.mediaThumbnails?.first?.value
    }

    public init(from entry: RSSFeedItem) {
        self.title = entry.title
        self.summary = entry.description
        self.authors = [entry.author].compactMap { $0 }
        self.link = entry.link
        self.updated = entry.pubDate
        self.categories = entry.categories?.compactMap { $0.value }
        self.content = entry.content?.contentEncoded
        self.published = entry.pubDate
        self.source = entry.source?.value
        self.rights = nil
        self.image = entry.enclosure?.attributes?.url
    }

    public init(from entry: JSONFeedItem) {
        self.title = entry.title
        self.summary = entry.summary
        self.authors = [entry.author?.name].compactMap { $0 }
        self.link = entry.url
        self.updated = entry.datePublished
        self.categories = entry.tags
        self.content = entry.contentText
        self.published = entry.datePublished
        self.source = nil
        self.rights = nil
        self.image = entry.image
    }

    public init(title: String?, summary: String?, authors: [String]?, link: String?, updated: Date?, categories: [String]?, content: String?, published: Date?, source: String?, rights: String?, image: String?) {
        self.title = title
        self.summary = summary
        self.authors = authors
        self.link = link
        self.updated = updated
        self.categories = categories
        self.content = content
        self.published = published
        self.source = source
        self.rights = rights
        self.image = image
    }

    public static let sample = NewsItem(
        title: "Lorem ipsum dolor sit amet consectetur adipiscing elit sodales hendrerit",
        summary: "Summary",
        authors: ["Author"],
        link: "https://sample.com",
        updated: Date(),
        categories: ["Category"],
        content: "Content",
        published: Date(),
        source: "Source",
        rights: "Rights",
        image: ""
    )
}

public extension NewsItem {
    func publishedDate() -> String {
        guard let date = published else { return "" }
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
