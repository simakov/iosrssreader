//
//  NewsItem.swift
//  NewsRSSReaderShared
//
//  Platform-agnostic model for iOS and watchOS
//

import Foundation

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

        dateFormatter.dateFormat = "HH:mm"

        let fullDateFormat = "d.MM HH:mm"
        fullDateFormatter.dateFormat = fullDateFormat

        let calendar = Calendar.current

        let components1 = calendar.dateComponents([.day, .month, .year], from: date)
        let components2 = calendar.dateComponents([.day, .month, .year], from: currentDate)

        if components1.day == components2.day && components1.month == components2.month && components1.year == components2.year {
            return dateFormatter.string(from: date)
        } else {
            return fullDateFormatter.string(from: date)
        }
    }
}
