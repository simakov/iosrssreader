//
//  LentaRSSParser.swift
//  NewsRSSReaderShared
//
//  Native RSS 2.0 parser using Foundation XMLParser
//

import Foundation

public final class LentaRSSParser: NSObject, XMLParserDelegate {

    // MARK: - Result storage
    private var items: [NewsItem] = []
    private var parseError: Error?

    // MARK: - Parse state
    private var isInsideItem = false
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentAuthor = ""
    private var currentDescription = ""
    private var currentCategory = ""
    private var currentPubDate = ""
    private var currentEnclosureURL = ""

    // MARK: - Date formatter (RFC 2822)
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return df
    }()

    // MARK: - Public API

    public func parse(data: Data) -> Result<[NewsItem], Error> {
        items = []
        parseError = nil

        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()

        if let error = parseError ?? parser.parserError {
            return .failure(error)
        }
        return .success(items)
    }

    // MARK: - XMLParserDelegate

    public func parser(_ parser: XMLParser, didStartElement elementName: String,
                       namespaceURI: String?, qualifiedName: String?,
                       attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName

        if elementName == "item" {
            isInsideItem = true
            currentTitle = ""
            currentLink = ""
            currentAuthor = ""
            currentDescription = ""
            currentCategory = ""
            currentPubDate = ""
            currentEnclosureURL = ""
        }

        if isInsideItem && elementName == "enclosure" {
            currentEnclosureURL = attributeDict["url"] ?? ""
        }
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isInsideItem else { return }
        switch currentElement {
        case "title": currentTitle += string
        case "link": currentLink += string
        case "author": currentAuthor += string
        case "description": currentDescription += string
        case "category": currentCategory += string
        case "pubDate": currentPubDate += string
        default: break
        }
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String,
                       namespaceURI: String?, qualifiedName: String?) {
        if elementName == "item" {
            isInsideItem = false
            let date = Self.dateFormatter.date(from: currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines))
            let item = NewsItem(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                summary: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? nil : currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                authors: currentAuthor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? nil : [currentAuthor.trimmingCharacters(in: .whitespacesAndNewlines)],
                link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
                updated: date,
                categories: currentCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? nil : [currentCategory.trimmingCharacters(in: .whitespacesAndNewlines)],
                content: nil,
                published: date,
                source: nil,
                rights: nil,
                image: currentEnclosureURL.isEmpty ? nil : currentEnclosureURL
            )
            items.append(item)
        }

        // Reset currentElement when closing any tag to avoid capturing whitespace between tags
        if isInsideItem {
            currentElement = ""
        }
    }

    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }
}
