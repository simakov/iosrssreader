//
//  SimpleHTMLParser.swift
//  NewsRSSReaderShared
//
//  Lightweight HTML parser replacing SwiftSoup dependency.
//  Supports DOM traversal, text/attribute access, and basic CSS selectors.
//

import Foundation

// MARK: - DOM Model

/// Represents a node in the HTML document tree
public protocol HTMLNode: AnyObject {}

/// Represents an HTML element with tag, attributes, and children
public final class HTMLElement: HTMLNode {
    public let tag: String
    public var attributes: [String: String]
    public var childNodes: [HTMLNode] = []
    public weak var parentElement: HTMLElement?

    init(tag: String, attributes: [String: String] = [:]) {
        self.tag = tag.lowercased()
        self.attributes = attributes
    }

    public func tagName() -> String { tag }

    public func attr(_ name: String) -> String {
        attributes[name.lowercased()] ?? ""
    }

    public func hasClass(_ cls: String) -> Bool {
        let classes = attributes["class"]?.split(separator: " ").map(String.init) ?? []
        return classes.contains(cls)
    }

    /// Returns only element children (no text nodes)
    public func children() -> [HTMLElement] {
        childNodes.compactMap { $0 as? HTMLElement }
    }

    /// Recursively collects text content from all descendants
    public func text() -> String {
        var parts: [String] = []
        collectText(into: &parts)
        return parts.joined(separator: " ")
            .replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func collectText(into parts: inout [String]) {
        for node in childNodes {
            if let textNode = node as? HTMLTextNode {
                let t = textNode.text.trimmingCharacters(in: .whitespacesAndNewlines)
                if !t.isEmpty { parts.append(t) }
            } else if let el = node as? HTMLElement {
                el.collectText(into: &parts)
            }
        }
    }

    /// Returns inner HTML (reconstructed)
    public func html() -> String {
        var result = ""
        for node in childNodes {
            if let textNode = node as? HTMLTextNode {
                result += textNode.text
            } else if let el = node as? HTMLElement {
                result += el.outerHTML()
            }
        }
        return result
    }

    private func outerHTML() -> String {
        var result = "<\(tag)"
        for (key, value) in attributes {
            result += " \(key)=\"\(value)\""
        }
        if SimpleHTMLParser.voidElements.contains(tag) {
            result += "/>"
        } else {
            result += ">"
            result += html()
            result += "</\(tag)>"
        }
        return result
    }

    /// CSS selector search within this element's subtree
    public func select(_ css: String) -> [HTMLElement] {
        let selectors = CSSSelector.parse(css)
        var results: [HTMLElement] = []
        collectMatching(selectors: selectors, into: &results)
        return results
    }

    private func collectMatching(selectors: [CSSSelector], into results: inout [HTMLElement]) {
        for child in children() {
            for selector in selectors {
                if selector.matches(child) {
                    results.append(child)
                    break
                }
            }
            child.collectMatching(selectors: selectors, into: &results)
        }
    }
}

/// Represents a text node in the HTML document
public final class HTMLTextNode: HTMLNode {
    public let text: String
    init(text: String) { self.text = text }
}

/// Root document container
public final class HTMLDocument {
    public let root: HTMLElement

    init(root: HTMLElement) { self.root = root }

    public func select(_ css: String) -> [HTMLElement] {
        root.select(css)
    }
}

// MARK: - Array extension for convenience

public extension Array where Element == HTMLElement {
    func first() -> HTMLElement? { self.first as HTMLElement? }
}

// MARK: - CSS Selector Mini-Engine

/// Represents a parsed CSS selector
struct CSSSelector {
    var tagName: String?       // e.g. "img", "div"
    var className: String?     // e.g. "picture__image"
    var attrName: String?      // e.g. "type"
    var attrValue: String?     // e.g. "application/ld+json"
    var attrMatch: AttrMatch = .exact

    enum AttrMatch {
        case exact      // [attr=value]
        case prefix     // [attr^=value]
    }

    func matches(_ element: HTMLElement) -> Bool {
        if let t = tagName, element.tag != t.lowercased() { return false }
        if let c = className, !element.hasClass(c) { return false }
        if let name = attrName {
            let val = element.attr(name)
            if let expected = attrValue {
                switch attrMatch {
                case .exact:  if val != expected { return false }
                case .prefix: if !val.hasPrefix(expected) { return false }
                }
            } else {
                if val.isEmpty { return false }
            }
        }
        return true
    }

    /// Parses a CSS selector string supporting comma-separated union
    static func parse(_ css: String) -> [CSSSelector] {
        css.split(separator: ",").map { part in
            parseSingle(String(part).trimmingCharacters(in: .whitespaces))
        }
    }

    private static func parseSingle(_ s: String) -> CSSSelector {
        var sel = CSSSelector()

        // Check for attribute selector [attr=value] or [attr^=value]
        if let bracketStart = s.firstIndex(of: "["),
           let bracketEnd = s.lastIndex(of: "]") {
            let prefix = String(s[s.startIndex..<bracketStart])
            let attrStr = String(s[s.index(after: bracketStart)..<bracketEnd])

            if !prefix.isEmpty {
                parseTagClass(prefix, into: &sel)
            }

            if attrStr.contains("^=") {
                let parts = attrStr.split(separator: "^", maxSplits: 1)
                sel.attrName = String(parts[0])
                if parts.count > 1 {
                    sel.attrValue = String(parts[1]).trimmingCharacters(in: CharacterSet(charactersIn: "=\"'"))
                }
                sel.attrMatch = .prefix
            } else if attrStr.contains("=") {
                let parts = attrStr.split(separator: "=", maxSplits: 1)
                sel.attrName = String(parts[0])
                if parts.count > 1 {
                    sel.attrValue = String(parts[1]).trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                }
                sel.attrMatch = .exact
            } else {
                sel.attrName = attrStr
            }
        } else {
            parseTagClass(s, into: &sel)
        }

        return sel
    }

    private static func parseTagClass(_ s: String, into sel: inout CSSSelector) {
        if let dotIndex = s.firstIndex(of: ".") {
            let tag = String(s[s.startIndex..<dotIndex])
            let cls = String(s[s.index(after: dotIndex)...])
            if !tag.isEmpty { sel.tagName = tag }
            if !cls.isEmpty { sel.className = cls }
        } else if s.hasPrefix(".") {
            // Already handled by the condition above if "." is at start
            // This case shouldn't happen, but handle defensively
            sel.className = String(s.dropFirst())
        } else if !s.isEmpty {
            sel.tagName = s
        }
    }
}

// MARK: - HTML Tokenizer / Parser

public struct SimpleHTMLParser {

    static let voidElements: Set<String> = [
        "area", "base", "br", "col", "embed", "hr", "img", "input",
        "link", "meta", "param", "source", "track", "wbr"
    ]

    private static let rawTextElements: Set<String> = ["script", "style"]

    /// Parses an HTML string into an HTMLDocument
    public static func parse(_ html: String) -> HTMLDocument {
        let root = HTMLElement(tag: "html")
        var stack: [HTMLElement] = [root]
        let chars = Array(html.unicodeScalars)
        let count = chars.count
        var i = 0

        while i < count {
            let ch = chars[i]

            if ch == "<" && i + 1 < count {
                // Check for comment
                if i + 3 < count && chars[i+1] == "-" && chars[i+2] == "-" {
                    // Skip comment
                    if let end = findCommentEnd(chars, from: i + 3) {
                        i = end
                    } else {
                        i = count
                    }
                    continue
                }

                // Check for <!DOCTYPE or <!
                if i + 1 < count && chars[i+1] == "!" {
                    if let end = indexOf(chars, char: ">", from: i + 2) {
                        i = end + 1
                    } else {
                        i = count
                    }
                    continue
                }

                // Close tag
                if i + 1 < count && chars[i+1] == "/" {
                    let (tagName, endIndex) = readCloseTag(chars, from: i + 2, count: count)
                    i = endIndex
                    if !tagName.isEmpty {
                        closeTag(tagName.lowercased(), stack: &stack)
                    }
                    continue
                }

                // Open tag
                let (tagName, attrs, selfClosing, endIndex) = readOpenTag(chars, from: i + 1, count: count)
                i = endIndex

                if tagName.isEmpty { continue }

                let lowerTag = tagName.lowercased()
                let element = HTMLElement(tag: lowerTag, attributes: attrs)
                element.parentElement = stack.last
                stack.last?.childNodes.append(element)

                if !selfClosing && !voidElements.contains(lowerTag) {
                    stack.append(element)

                    // Handle raw text elements (script, style)
                    if rawTextElements.contains(lowerTag) {
                        let (rawText, rawEnd) = readRawText(chars, tag: lowerTag, from: i, count: count)
                        if !rawText.isEmpty {
                            element.childNodes.append(HTMLTextNode(text: rawText))
                        }
                        i = rawEnd
                        _ = stack.popLast()
                    }
                }
            } else {
                // Text content
                let (text, endIndex) = readText(chars, from: i, count: count)
                i = endIndex
                let decoded = decodeEntities(text)
                if !decoded.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    stack.last?.childNodes.append(HTMLTextNode(text: decoded))
                }
            }
        }

        return HTMLDocument(root: root)
    }

    // MARK: - Tokenizer Helpers

    private static func readText(_ chars: [Unicode.Scalar], from start: Int, count: Int) -> (String, Int) {
        var i = start
        var result = ""
        while i < count && chars[i] != "<" {
            result.unicodeScalars.append(chars[i])
            i += 1
        }
        return (result, i)
    }

    private static func readCloseTag(_ chars: [Unicode.Scalar], from start: Int, count: Int) -> (String, Int) {
        var i = start
        var tagName = ""
        // Skip whitespace
        while i < count && isWhitespace(chars[i]) { i += 1 }
        // Read tag name
        while i < count && chars[i] != ">" && !isWhitespace(chars[i]) {
            tagName.unicodeScalars.append(chars[i])
            i += 1
        }
        // Skip to >
        while i < count && chars[i] != ">" { i += 1 }
        if i < count { i += 1 } // skip >
        return (tagName, i)
    }

    private static func readOpenTag(_ chars: [Unicode.Scalar], from start: Int, count: Int) -> (String, [String: String], Bool, Int) {
        var i = start
        var tagName = ""
        var attrs: [String: String] = [:]
        var selfClosing = false

        // Read tag name
        while i < count && chars[i] != ">" && chars[i] != "/" && !isWhitespace(chars[i]) {
            tagName.unicodeScalars.append(chars[i])
            i += 1
        }

        // Read attributes
        while i < count && chars[i] != ">" {
            if chars[i] == "/" {
                selfClosing = true
                i += 1
                continue
            }
            if isWhitespace(chars[i]) {
                i += 1
                continue
            }

            // Read attribute name
            var attrName = ""
            while i < count && chars[i] != "=" && chars[i] != ">" && chars[i] != "/" && !isWhitespace(chars[i]) {
                attrName.unicodeScalars.append(chars[i])
                i += 1
            }

            // Skip whitespace
            while i < count && isWhitespace(chars[i]) { i += 1 }

            if i < count && chars[i] == "=" {
                i += 1
                // Skip whitespace
                while i < count && isWhitespace(chars[i]) { i += 1 }

                var attrValue = ""
                if i < count && (chars[i] == "\"" || chars[i] == "'") {
                    let quote = chars[i]
                    i += 1
                    while i < count && chars[i] != quote {
                        attrValue.unicodeScalars.append(chars[i])
                        i += 1
                    }
                    if i < count { i += 1 } // skip closing quote
                } else {
                    // Unquoted attribute value
                    while i < count && chars[i] != ">" && chars[i] != "/" && !isWhitespace(chars[i]) {
                        attrValue.unicodeScalars.append(chars[i])
                        i += 1
                    }
                }
                if !attrName.isEmpty {
                    attrs[attrName.lowercased()] = decodeEntities(attrValue)
                }
            } else if !attrName.isEmpty {
                attrs[attrName.lowercased()] = ""
            }
        }

        if i < count { i += 1 } // skip >
        return (tagName, attrs, selfClosing, i)
    }

    private static func readRawText(_ chars: [Unicode.Scalar], tag: String, from start: Int, count: Int) -> (String, Int) {
        let closeTag = "</\(tag)"
        let closeChars = Array(closeTag.unicodeScalars)
        var i = start
        var result = ""

        while i < count {
            // Check for close tag (case-insensitive)
            if chars[i] == "<" && i + closeChars.count <= count {
                var matched = true
                for j in 0..<closeChars.count {
                    let a = chars[i + j]
                    let b = closeChars[j]
                    if a != b && Character(a).lowercased() != Character(b).lowercased() {
                        matched = false
                        break
                    }
                }
                if matched {
                    // Skip past the closing tag
                    var k = i + closeChars.count
                    while k < count && chars[k] != ">" { k += 1 }
                    if k < count { k += 1 }
                    return (result, k)
                }
            }
            result.unicodeScalars.append(chars[i])
            i += 1
        }
        return (result, i)
    }

    private static func closeTag(_ tagName: String, stack: inout [HTMLElement]) {
        // Find matching open tag in stack, close everything up to it
        for j in stride(from: stack.count - 1, through: 1, by: -1) {
            if stack[j].tag == tagName {
                stack.removeSubrange(j...)
                return
            }
        }
    }

    private static func findCommentEnd(_ chars: [Unicode.Scalar], from start: Int) -> Int? {
        var i = start
        let count = chars.count
        while i + 2 < count {
            if chars[i] == "-" && chars[i+1] == "-" && chars[i+2] == ">" {
                return i + 3
            }
            i += 1
        }
        return nil
    }

    private static func indexOf(_ chars: [Unicode.Scalar], char: Unicode.Scalar, from start: Int) -> Int? {
        var i = start
        while i < chars.count {
            if chars[i] == char { return i }
            i += 1
        }
        return nil
    }

    private static func isWhitespace(_ c: Unicode.Scalar) -> Bool {
        c == " " || c == "\t" || c == "\n" || c == "\r" || c == "\u{000C}"
    }

    // MARK: - HTML Entity Decoding

    private static func decodeEntities(_ s: String) -> String {
        guard s.contains("&") else { return s }
        var result = ""
        let chars = Array(s.unicodeScalars)
        var i = 0
        let count = chars.count

        while i < count {
            if chars[i] == "&" {
                // Try to decode entity
                if let (decoded, end) = decodeEntity(chars, from: i, count: count) {
                    result += decoded
                    i = end
                    continue
                }
            }
            result.unicodeScalars.append(chars[i])
            i += 1
        }
        return result
    }

    private static func decodeEntity(_ chars: [Unicode.Scalar], from start: Int, count: Int) -> (String, Int)? {
        var i = start + 1 // skip &
        var name = ""

        while i < count && chars[i] != ";" && name.count < 10 {
            name.unicodeScalars.append(chars[i])
            i += 1
        }

        guard i < count && chars[i] == ";" else { return nil }
        i += 1 // skip ;

        // Named entities
        switch name {
        case "amp": return ("&", i)
        case "lt": return ("<", i)
        case "gt": return (">", i)
        case "quot": return ("\"", i)
        case "apos": return ("'", i)
        case "nbsp": return ("\u{00A0}", i)
        default: break
        }

        // Numeric entities
        if name.hasPrefix("#x") || name.hasPrefix("#X") {
            let hex = String(name.dropFirst(2))
            if let code = UInt32(hex, radix: 16), let scalar = Unicode.Scalar(code) {
                return (String(scalar), i)
            }
        } else if name.hasPrefix("#") {
            let dec = String(name.dropFirst())
            if let code = UInt32(dec), let scalar = Unicode.Scalar(code) {
                return (String(scalar), i)
            }
        }

        return nil
    }
}
