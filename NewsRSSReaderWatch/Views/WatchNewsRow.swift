//
//  WatchNewsRow.swift
//  NewsRSSReaderWatch
//
//  News item row for watch list
//

import SwiftUI
import NewsRSSReaderShared

struct WatchNewsRow: View {
    let item: NewsItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = item.title {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Black"))
                    .lineLimit(3)
            }

            HStack {
                Text(item.publishedDate())
                    .font(.system(size: 11))
                    .foregroundColor(Color("Gray"))

                if let category = item.categories?.first {
                    Text("• \(category)")
                        .font(.system(size: 11))
                        .foregroundColor(Color("Gray"))
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        WatchNewsRow(item: NewsItem.sample)
        WatchNewsRow(item: NewsItem.sample)
    }
}
