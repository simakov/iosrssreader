//
//  LentaFeedService.swift
//  NewsRSSReaderShared
//
//  Platform-agnostic RSS feed service for iOS and watchOS
//

import Foundation

public class LentaFeedService {
    let basePath = "https://lenta.ru/rss"

    public enum Source: String {
        case top7 = "top7"
        case last24 = "last24"
        case all = "news"
    }

    public let categories: [String: String] = [
        "russia": "Россия",
        "world": "Мир",
        "ussr": "Бывший СССР",
        "economics": "Экономика",
        "forces": "Силовые структуры",
        "science": "Наука и техника",
        "culture": "Культура",
        "sport": "Спорт",
        "media": "Интернет и СМИ",
        "style": "Ценности",
        "travel": "Путешествия",
        "life": "Из жизни",
        "realty": "Среда обитания",
        "wellness": "Забота о себе",
        "pobeda80": "Победа"
    ]

    public static let shared = LentaFeedService()

    private let urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()

    // App Groups for shared data between app and widget
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: "group.net.idscan.lentareader.newsrssreader")
    }

    private init() {}

    public func getFeed(source: Source, category: String? = nil, completion: @escaping (Result<[NewsItem], Error>) -> Void) {
        var urlComponents = [basePath, source.rawValue]
        if let category = category {
            urlComponents.append(category)
        }
        guard let feedURL = URL(string: urlComponents.joined(separator: "/")) else { return }

        urlSession.dataTask(with: feedURL) { [weak self] data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "LentaFeedService", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            let result = LentaRSSParser().parse(data: data)

            if case .success(let items) = result, source == .top7 && category == nil {
                self?.cacheTopNews(items)
            }

            completion(result)
        }.resume()
    }

    // MARK: - Caching for Widget

    public func cacheTopNews(_ items: [NewsItem]) {
        guard let encoded = try? JSONEncoder().encode(items) else {
            print("[LentaFeedService] Failed to encode news items for caching")
            return
        }
        guard let defaults = userDefaults else {
            print("[LentaFeedService] App Group UserDefaults not available, skipping cache")
            return
        }
        defaults.set(encoded, forKey: "cachedTopNews")
    }

    public func getCachedTopNews() -> [NewsItem]? {
        guard let defaults = userDefaults else { return nil }
        guard let data = defaults.data(forKey: "cachedTopNews") else { return nil }
        return try? JSONDecoder().decode([NewsItem].self, from: data)
    }
}
