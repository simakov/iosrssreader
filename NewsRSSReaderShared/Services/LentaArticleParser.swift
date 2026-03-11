//
//  LentaArticleParser.swift
//  NewsRSSReaderShared
//
//  Platform-agnostic HTML parser for iOS and watchOS
//

import Foundation

/// HTML parser for articles from Lenta.ru website
public class LentaArticleParser {
    /// Singleton instance
    public static let shared = LentaArticleParser()

    private init() {}

    /// Parses HTML article page into structured content
    /// - Parameters:
    ///   - html: HTML string of the page
    ///   - existingNewsItem: Existing NewsItem with data from RSS (title, image, date)
    /// - Returns: ArticleContent or nil in case of parsing error
    public func parse(html: String, existingNewsItem: NewsItem) -> ArticleContent? {
        let doc = SimpleHTMLParser.parse(html)

        // Parse metadata
        let metadata = parseMetadata(doc: doc)

        // Parse author separately (usually before article body)
        var author: ArticleContentType? = nil
        if let authorBlock = doc.select(".topic-authors").first() {
            author = parseAuthor(element: authorBlock)
        }

        // Collect content
        var content: [ArticleContentType] = []

        // Add author at the beginning if present
        if let authorContent = author {
            content.append(authorContent)
        }

        // Try to find content in different possible containers
        // Order of attempts:
        // 1. .content-body (current Lenta.ru structure)
        // 2. .topic-body__content (old structure)
        // 3. .topic-body (intermediate structure)
        // 4. articleBody_ (most generic container)
        var body = doc.select(".content-body").first()
        if body == nil {
            body = doc.select(".topic-body__content").first()
        }
        if body == nil {
            body = doc.select(".topic-body").first()
        }
        if body == nil {
            body = doc.select("[id^=articleBody_]").first()
        }

        if let body = body {
            let children = body.children()

            for child in children {
                if let contentItem = parseContentElement(element: child) {
                    content.append(contentItem)
                }
            }
        }

        // Fallback: try to extract text from JSON-LD structured data
        if content.isEmpty {
            let jsonLDContent = self.parseJSONLD(doc: doc)
            content.append(contentsOf: jsonLDContent)
        }

        return ArticleContent(
            title: existingNewsItem.title ?? "",
            image: existingNewsItem.image,
            publishedDate: existingNewsItem.published ?? metadata.date,
            category: metadata.category,
            content: content
        )
    }

    // MARK: - Private Parsing Methods

    /// Parses article metadata (category, date)
    private func parseMetadata(doc: HTMLDocument) -> (category: String?, date: Date?) {
        var category: String? = nil
        let date: Date? = nil

        // Parse category
        if let categoryElement = doc.select(".topic-header__rubric").first() {
            category = categoryElement.text()
        }

        return (category: category, date: date)
    }

    /// Parses author block
    private func parseAuthor(element: HTMLElement) -> ArticleContentType? {
        let name = element.select(".topic-authors__name").first()?.text() ?? ""
        let photo = element.select(".topic-authors__photo").first()?.attr("src") ?? ""
        let jobTitle = element.select(".topic-authors__job").first()?.text()

        if !name.isEmpty {
            return .author(
                name: name,
                photo: photo.isEmpty ? nil : photo,
                jobTitle: jobTitle
            )
        }

        return nil
    }

    /// Parses individual content element
    private func parseContentElement(element: HTMLElement) -> ArticleContentType? {
        let tagName = element.tagName()

        // Text paragraph - try different class variants
        if tagName == "p" {
            let text = element.text()
            let isLead = element.hasClass("_lead") || element.hasClass("topic-body__content-text--lead")

            if !text.isEmpty {
                return .paragraph(text: text, isLead: isLead)
            }
        }

        // Subheading - try h2, h3
        else if (tagName == "h2" || tagName == "h3") {
            let text = element.text()

            if !text.isEmpty {
                return .subheading(text: text)
            }
        }

        // Image
        else if tagName == "figure" && element.hasClass("picture") {
            return parseImage(element: element)
        }

        // Quote
        else if tagName == "div" && element.hasClass("box-quote") {
            return parseQuote(element: element)
        }

        // Info box
        else if tagName == "div" && element.hasClass("box-note") {
            return parseInfoBox(element: element)
        }

        // Related materials
        else if tagName == "div" && element.hasClass("box-inline-topic") {
            return parseRelatedMaterial(element: element)
        }

        return nil
    }

    /// Parses image with caption
    private func parseImage(element: HTMLElement) -> ArticleContentType? {
        let imgElement = element.select("img.picture__image").first()
        let url = imgElement?.attr("src") ?? ""

        // Parse caption and credits
        var caption: String? = nil
        var credit: String? = nil

        if let figcaption = element.select("figcaption.description").first() {
            // Credits/authorship
            if let creditsElement = figcaption.select(".description__credits").first() {
                credit = creditsElement.text()
            }

            // Description (if there's other text besides credits)
            let fullText = figcaption.text()
            if let cred = credit {
                caption = fullText.replacingOccurrences(of: cred, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if caption?.isEmpty == true {
                    caption = nil
                }
            }
        }

        if !url.isEmpty {
            return .image(url: url, caption: caption, credit: credit)
        }

        return nil
    }

    /// Parses quote block
    private func parseQuote(element: HTMLElement) -> ArticleContentType? {
        let quoteText = element.select(".box-quote__content-text").first()?.text() ?? ""
        let authorName = element.select(".box-quote__author-name").first()?.text() ?? ""
        let authorDescription = element.select(".box-quote__author-description").first()?.text()

        if !quoteText.isEmpty {
            return .quote(
                text: quoteText,
                authorName: authorName,
                authorDescription: authorDescription
            )
        }

        return nil
    }

    /// Parses info box
    private func parseInfoBox(element: HTMLElement) -> ArticleContentType? {
        let text = element.select(".box-note__text").first()?.text() ?? ""

        if !text.isEmpty {
            return .infoBox(text: text)
        }

        return nil
    }

    /// Parses related materials
    private func parseRelatedMaterial(element: HTMLElement) -> ArticleContentType? {
        if let card = element.select(".card-inline-topic").first() {
            let title = card.select(".card-inline-topic__title").first()?.text() ?? ""
            let description = card.select(".card-inline-topic__rightcol").first()?.text()
            let imageUrl = card.select(".card-inline-topic__image").first()?.attr("src")
            let articleUrl = card.attr("href")
            let date = card.select(".card-inline-topic__date").first()?.text()

            if !title.isEmpty && !articleUrl.isEmpty {
                let fullUrl = articleUrl.hasPrefix("http") ? articleUrl : "https://lenta.ru\(articleUrl)"

                return .relatedMaterial(
                    title: title,
                    description: description,
                    imageUrl: imageUrl,
                    articleUrl: fullUrl,
                    date: date
                )
            }
        }

        return nil
    }
    
    /// Parses JSON-LD structured data from script tag
    /// Returns array of content items (author + article body)
    private func parseJSONLD(doc: HTMLDocument) -> [ArticleContentType] {
        var content: [ArticleContentType] = []

        let scripts = doc.select("script[type=application/ld+json]")

        for script in scripts {
            let jsonString = script.html()

            guard let jsonData = jsonString.data(using: .utf8) else { continue }

            if let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {

                if let authorDict = json["author"] as? [String: Any],
                   let authorName = authorDict["name"] as? String,
                   !authorName.isEmpty {

                    content.append(.author(
                        name: authorName,
                        photo: nil,
                        jobTitle: nil
                    ))
                }

                if let articleBody = json["articleBody"] as? String,
                   !articleBody.isEmpty {
                    content.append(.paragraph(text: articleBody, isLead: false))
                }

                if !content.isEmpty {
                    break
                }
            }
        }

        return content
    }
}
