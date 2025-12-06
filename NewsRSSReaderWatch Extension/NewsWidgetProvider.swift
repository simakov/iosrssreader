//
//  NewsWidgetProvider.swift
//  NewsRSSReaderWatch Extension
//
//  Widget timeline provider
//

import WidgetKit
import NewsRSSReaderShared

struct NewsWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> NewsWidgetEntry {
        NewsWidgetEntry(
            date: Date(),
            newsItems: [NewsItem.sample]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NewsWidgetEntry) -> Void) {
        let entry = NewsWidgetEntry(
            date: Date(),
            newsItems: [NewsItem.sample]
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NewsWidgetEntry>) -> Void) {
        // Load latest news
        LentaFeedService.shared.getFeed(source: .top7) { result in
            let entry: NewsWidgetEntry

            switch result {
            case .success(let items):
                entry = NewsWidgetEntry(
                    date: Date(),
                    newsItems: Array(items.prefix(5)) // Take top 5
                )
            case .failure:
                // Fallback: try to get cached data
                let cached = LentaFeedService.shared.getCachedTopNews() ?? []
                entry = NewsWidgetEntry(
                    date: Date(),
                    newsItems: cached.isEmpty ? [NewsItem.sample] : Array(cached.prefix(5))
                )
            }

            // Update every 30 minutes
            let nextUpdate = Calendar.current.date(
                byAdding: .minute,
                value: 30,
                to: Date()
            )!

            let timeline = Timeline(
                entries: [entry],
                policy: .after(nextUpdate)
            )

            completion(timeline)
        }
    }
}
