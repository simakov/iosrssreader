//
//  LentaArticleParser.swift
//  NewsRSSReaderShared
//
//  Platform-agnostic HTML parser for iOS and watchOS
//

import Foundation
import SwiftSoup

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
        do {
            let doc = try SwiftSoup.parse(html)

            // Parse metadata
            let metadata = parseMetadata(doc: doc)

            // Parse author separately (usually before article body)
            var author: ArticleContentType? = nil
            if let authorBlock = try? doc.select(".topic-authors").first() {
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
            var body = try? doc.select(".content-body").first()
            if body == nil {
                body = try? doc.select(".topic-body__content").first()
            }
            if body == nil {
                body = try? doc.select(".topic-body").first()
            }
            if body == nil {
                body = try? doc.select("[id^=articleBody_]").first()
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

        } catch {
            return nil
        }
    }

    // MARK: - Private Parsing Methods

    /// Parses article metadata (category, date)
    private func parseMetadata(doc: Document) -> (category: String?, date: Date?) {
        var category: String? = nil
        let date: Date? = nil

        // Parse category
        if let categoryElement = try? doc.select(".topic-header__rubric").first() {
            category = try? categoryElement.text()
        }

        // Parse date (already in NewsItem, but can supplement)
        if let timeElement = try? doc.select(".topic-header__time, .premium-header__time").first() {
            let dateString = try? timeElement.text()
            // TODO: Can add date parsing from string if needed
        }

        return (category: category, date: date)
    }

    /// Parses author block
    private func parseAuthor(element: Element) -> ArticleContentType? {
        do {
            let name = try element.select(".topic-authors__name").first()?.text() ?? ""
            let photo = try element.select(".topic-authors__photo").attr("src")
            let jobTitle = try element.select(".topic-authors__job").first()?.text()

            if !name.isEmpty {
                return .author(
                    name: name,
                    photo: photo.isEmpty ? nil : photo,
                    jobTitle: jobTitle
                )
            }
        } catch {
            // Ignore parsing errors
        }

        return nil
    }

    /// Parses individual content element
    private func parseContentElement(element: Element) -> ArticleContentType? {
        do {
            let tagName = element.tagName()

            // Text paragraph - try different class variants
            if tagName == "p" {
                // Old classes: topic-body__content-text
                // New classes: may be just <p> without special classes
                let text = try element.text()
                let isLead = element.hasClass("_lead") || element.hasClass("topic-body__content-text--lead")

                if !text.isEmpty {
                    return .paragraph(text: text, isLead: isLead)
                }
            }

            // Subheading - try h2, h3
            else if (tagName == "h2" || tagName == "h3") {
                let text = try element.text()

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

        } catch {
            // Ignore parsing errors
        }

        return nil
    }

    /// Parses image with caption
    private func parseImage(element: Element) -> ArticleContentType? {
        do {
            let imgElement = try element.select("img.picture__image").first()
            let url = try imgElement?.attr("src") ?? ""

            // Parse caption and credits
            var caption: String? = nil
            var credit: String? = nil

            if let figcaption = try? element.select("figcaption.description").first() {
                // Credits/authorship
                if let creditsElement = try? figcaption.select(".description__credits").first() {
                    credit = try creditsElement.text()
                }

                // Description (if there's other text besides credits)
                let fullText = try? figcaption.text()
                if let full = fullText, let cred = credit {
                    caption = full.replacingOccurrences(of: cred, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    if caption?.isEmpty == true {
                        caption = nil
                    }
                }
            }

            if !url.isEmpty {
                return .image(url: url, caption: caption, credit: credit)
            }

        } catch {
            // Ignore parsing errors
        }

        return nil
    }

    /// Parses quote block
    private func parseQuote(element: Element) -> ArticleContentType? {
        do {
            let quoteText = try element.select(".box-quote__content-text").first()?.text() ?? ""
            let authorName = try element.select(".box-quote__author-name").first()?.text() ?? ""
            let authorDescription = try element.select(".box-quote__author-description").first()?.text()

            if !quoteText.isEmpty {
                return .quote(
                    text: quoteText,
                    authorName: authorName,
                    authorDescription: authorDescription
                )
            }

        } catch {
            // Ignore parsing errors
        }

        return nil
    }

    /// Parses info box
    private func parseInfoBox(element: Element) -> ArticleContentType? {
        do {
            let text = try element.select(".box-note__text").first()?.text() ?? ""

            if !text.isEmpty {
                return .infoBox(text: text)
            }

        } catch {
            // Ignore parsing errors
        }

        return nil
    }

    /// Parses related materials
    private func parseRelatedMaterial(element: Element) -> ArticleContentType? {
        do {
            // Take the first related material card
            if let card = try? element.select(".card-inline-topic").first() {
                let title = try card.select(".card-inline-topic__title").first()?.text() ?? ""
                let description = try? card.select(".card-inline-topic__rightcol").first()?.text()
                let imageUrl = try? card.select(".card-inline-topic__image").attr("src")
                let articleUrl = try card.attr("href")
                let date = try? card.select(".card-inline-topic__date").first()?.text()

                if !title.isEmpty && !articleUrl.isEmpty {
                    // Form full URL if it's a relative path
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

        } catch {
            // Ignore parsing errors
        }

        return nil
    }
    
    /// Parses JSON-LD structured data from script tag
    /// Returns array of content items (author + article body)
    private func parseJSONLD(doc: Document) -> [ArticleContentType] {
        var content: [ArticleContentType] = []
        
        do {
            // Find script tag with type="application/ld+json"
            let scripts = try doc.select("script[type=application/ld+json]")
            
            for script in scripts {
                let jsonString = try script.html()
                
                guard let jsonData = jsonString.data(using: .utf8) else { continue }
                
                if let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    
                    // Extract author information
                    if let authorDict = json["author"] as? [String: Any],
                       let authorName = authorDict["name"] as? String,
                       !authorName.isEmpty {
                        
                        // URL can contain author's page link
                        // Photo is usually not in JSON-LD, but we can check
                        let authorUrl = authorDict["url"] as? String
                        
                        content.append(.author(
                            name: authorName,
                            photo: nil, // JSON-LD usually doesn't have author photo
                            jobTitle: nil // Can add if needed
                        ))
                    }
                    
                    // Extract article body
                    if let articleBody = json["articleBody"] as? String,
                       !articleBody.isEmpty {
                        content.append(.paragraph(text: articleBody, isLead: false))
                    }
                    
                    // If we found something, break out of loop
                    if !content.isEmpty {
                        break
                    }
                }
            }
        } catch {
            // Ignore parsing errors
        }
        
        return content
    }
}
