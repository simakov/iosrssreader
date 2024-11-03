import FeedKit
import Foundation

class LentaFeedService {
    let basePath = "https://api.lenta.ru/rss/"
    enum Source: String {
        case top7 = "top7"
        case last24 = "last24"
        case all = ""
    }
    static let shared = LentaFeedService()
    private init() {}

    func getFeed(source: Source, completion: @escaping (Result<[NewsItem], Error>) -> Void) {
        guard let feedURL = URL(string: basePath + "/" + source.rawValue) else { return }
            let parser = FeedParser(URL: feedURL)
            parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
                DispatchQueue.main.async {
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
}
