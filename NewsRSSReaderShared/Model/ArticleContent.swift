//
//  ArticleContent.swift
//  NewsRSSReaderShared
//
//  Platform-agnostic model for iOS and watchOS
//

import Foundation

/// Article content types for native rendering
public enum ArticleContentType {
    /// Text paragraph
    case paragraph(text: String, isLead: Bool = false)

    /// Subheading (h2)
    case subheading(text: String)

    /// Image with caption and authorship
    case image(url: String, caption: String?, credit: String?)

    /// Quote with author
    case quote(text: String, authorName: String, authorDescription: String?)

    /// Article author information
    case author(name: String, photo: String?, jobTitle: String?)

    /// Highlighted info box
    case infoBox(text: String)

    /// Related materials (parsed but not shown yet)
    case relatedMaterial(title: String, description: String?, imageUrl: String?, articleUrl: String, date: String?)
}

/// Article content model after HTML parsing
public struct ArticleContent {
    /// Article title
    public let title: String

    /// Main image URL
    public let image: String?

    /// Publication date
    public let publishedDate: Date?

    /// Article category
    public let category: String?

    /// Array of content elements
    public let content: [ArticleContentType]

    public init(title: String, image: String?, publishedDate: Date?, category: String?, content: [ArticleContentType]) {
        self.title = title
        self.image = image
        self.publishedDate = publishedDate
        self.category = category
        self.content = content
    }
}
