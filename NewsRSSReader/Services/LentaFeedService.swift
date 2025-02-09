import FeedKit
import Foundation

class LentaFeedService {
    let basePath = "https://lenta.ru/rss"
    enum Source: String {
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

    static let shared = LentaFeedService()
    private init() {}

    func getFeed(source: Source, category: String? = nil, completion: @escaping (Result<[NewsItem], Error>) -> Void) {
        var urlString = [basePath, source.rawValue]
        if let category = category {
            urlString.append(category)
        }
        guard let feedURL = URL(string: urlString.joined(separator: "/")) else { return }
            let parser = FeedParser(URL: feedURL)
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            switch result {
            case .success(let feed):
                switch feed {
                case let .atom(atom):
                    guard let entries = atom.entries else {
                        completion(.failure(NSError()))
                        return
                    }
                    completion(.success(entries.compactMap { NewsItem(from: $0) }))
                    break
                case .json(let json):
                    guard let entries = json.items else {
                        completion(.failure(NSError()))
                        return
                    }
                    completion(.success(entries.compactMap { NewsItem(from: $0) }))
                case let .rss(feed):
                    guard let entries = feed.items else {
                        completion(.failure(NSError()))
                        return
                    }
                    completion(.success(entries.compactMap { NewsItem(from: $0) }))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
