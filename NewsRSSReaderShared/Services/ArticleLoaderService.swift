//
//  ArticleLoaderService.swift
//  NewsRSSReaderShared
//
//  Platform-agnostic version for iOS and watchOS
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

/// Service for loading HTML article content
public class ArticleLoaderService {
    /// Singleton instance
    public static let shared = ArticleLoaderService()

    /// Custom URLSession with settings to mimic Safari
    private lazy var safariSession: URLSession = {
        let config = URLSessionConfiguration.default

        // Cache settings like Safari
        config.requestCachePolicy = .useProtocolCachePolicy
        config.urlCache = URLCache.shared

        // HTTP settings
        config.httpShouldSetCookies = true
        config.httpCookieAcceptPolicy = .always
        config.httpShouldUsePipelining = true
        config.httpMaximumConnectionsPerHost = 6

        // Security settings
        config.tlsMinimumSupportedProtocolVersion = .TLSv12

        // Timeout - reduce for watchOS
        #if os(watchOS)
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        #else
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        #endif

        // Default headers
        config.httpAdditionalHeaders = self.getSafariHeaders()

        return URLSession(configuration: config)
    }()

    private init() {}

    /// Loading errors
    public enum LoaderError: LocalizedError {
        case invalidURL
        case networkError(Error)
        case invalidResponse
        case noData

        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL address"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid server response"
            case .noData:
                return "No data received"
            }
        }
    }

    /// Returns current Safari headers for current platform
    private func getSafariHeaders() -> [String: String] {
        #if os(iOS)
        let systemVersion = UIDevice.current.systemVersion
        let deviceModel = UIDevice.current.model
        let versionComponents = systemVersion.split(separator: ".").map { String($0) }
        let majorVersion = versionComponents.first ?? "18"
        let userAgent = "Mozilla/5.0 (\(deviceModel); CPU iPhone OS \(systemVersion.replacingOccurrences(of: ".", with: "_")) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(majorVersion).0 Mobile/15E148 Safari/604.1"

        #elseif os(watchOS)
        let systemVersion = WKInterfaceDevice.current().systemVersion
        let versionComponents = systemVersion.split(separator: ".").map { String($0) }
        let majorVersion = versionComponents.first ?? "10"
        let userAgent = "Mozilla/5.0 (Apple Watch; watchOS \(systemVersion.replacingOccurrences(of: ".", with: "_"))) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(majorVersion).0 Safari/604.1"
        #endif

        return [
            // Current User-Agent
            "User-Agent": userAgent,

            // Accept headers like Safari
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7",
            "Accept-Encoding": "gzip, deflate, br",

            // Additional headers
            "DNT": "1",
            "Connection": "keep-alive",
            "Upgrade-Insecure-Requests": "1",
            "Sec-Fetch-Dest": "document",
            "Sec-Fetch-Mode": "navigate",
            "Sec-Fetch-Site": "none"
        ]
    }

    /// Loads HTML content from specified URL
    /// - Parameters:
    ///   - url: Article URL address
    ///   - completion: Completion handler with result (HTML string or error)
    public func loadArticle(url: String, completion: @escaping (Result<String, LoaderError>) -> Void) {
        // Check URL validity
        guard let articleURL = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }

        // Create URLRequest with Safari headers
        var request = URLRequest(url: articleURL)
        request.httpMethod = "GET"
        request.cachePolicy = .useProtocolCachePolicy

        // Add Referer if this is an internal link
        if articleURL.host?.contains("lenta.ru") == true {
            request.setValue("https://lenta.ru/", forHTTPHeaderField: "Referer")
        }

        // Execute request through custom session
        let task = safariSession.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }

            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }

            // Check data presence
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            // Convert data to string
            // Try different encodings
            var htmlString: String?

            // First try UTF-8
            if let string = String(data: data, encoding: .utf8) {
                htmlString = string
            }
            // Then try Windows-1251 (may be used on some Russian sites)
            else if let string = String(data: data, encoding: .windowsCP1251) {
                htmlString = string
            }
            // Fallback to ISO Latin 1
            else if let string = String(data: data, encoding: .isoLatin1) {
                htmlString = string
            }

            guard let html = htmlString else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            // Return successful result
            DispatchQueue.main.async {
                completion(.success(html))
            }
        }

        task.resume()
    }
}
