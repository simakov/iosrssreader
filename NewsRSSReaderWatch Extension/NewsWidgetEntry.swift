//
//  NewsWidgetEntry.swift
//  NewsRSSReaderWatch Extension
//
//  Widget timeline entry
//

import WidgetKit
import NewsRSSReaderShared

struct NewsWidgetEntry: TimelineEntry {
    let date: Date
    let newsItems: [NewsItem]
}
