//
//  NewsWidget.swift
//  NewsRSSReaderWatch Extension
//
//  Widget configuration and views
//

import WidgetKit
import SwiftUI
import NewsRSSReaderShared

struct NewsWidget: Widget {
    let kind: String = "NewsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NewsWidgetProvider()) { entry in
            NewsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Лента.ру")
        .description("Последние новости с Lenta.ru")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner
        ])
    }
}

struct NewsWidgetEntryView: View {
    var entry: NewsWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularComplicationView(entry: entry)

        case .accessoryRectangular:
            RectangularComplicationView(entry: entry)

        case .accessoryInline:
            InlineComplicationView(entry: entry)

        case .accessoryCorner:
            CornerComplicationView(entry: entry)

        @unknown default:
            Text("News")
        }
    }
}

// MARK: - Complication Views

/// Circular complication (round widget)
struct CircularComplicationView: View {
    let entry: NewsWidgetEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: "newspaper")
                    .font(.system(size: 20))
                if !entry.newsItems.isEmpty {
                    Text("\(entry.newsItems.count)")
                        .font(.system(size: 14, weight: .bold))
                }
            }
        }
    }
}

/// Rectangular complication (rectangular widget)
struct RectangularComplicationView: View {
    let entry: NewsWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "newspaper")
                Text("Лента.ру")
                    .font(.system(size: 12, weight: .semibold))
            }

            if let first = entry.newsItems.first {
                Text(first.title ?? "")
                    .font(.system(size: 11))
                    .lineLimit(2)
            } else {
                Text("Нет новостей")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Inline complication (inline text)
struct InlineComplicationView: View {
    let entry: NewsWidgetEntry

    var body: some View {
        if let first = entry.newsItems.first {
            Text(first.title ?? "Лента.ру")
                .lineLimit(1)
        } else {
            Text("Лента.ру")
        }
    }
}

/// Corner complication (corner widget for Infograph)
struct CornerComplicationView: View {
    let entry: NewsWidgetEntry

    var body: some View {
        Text("\(entry.newsItems.count)")
            .font(.system(size: 24, weight: .bold))
            .widgetLabel {
                Image(systemName: "newspaper")
            }
    }
}
