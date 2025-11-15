//
//  CategoryView.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 04.11.2024.
//

import SwiftUI

struct CategoryView: View {
    @Binding var news: [NewsItem]
    var title: String
    var body: some View {
        LazyVStack(alignment: .leading) {
            Text(title)
                .foregroundColor(Color("Black"))
                .font(.system(size: 22, weight: .semibold))
                .id(0)
                .padding(.top, 10)
                .padding(.leading, 10)
            if news.count == 0 {
                ForEach(0..<7) { _ in
                    NewsView(data: NewsItem.sample)
                        .redacted(reason: .placeholder)
                        .shimmering()
                }
            } else {
                ForEach(news) { item in
                    if let link = item.link {
                        NavigationLink(
                            destination: ArticleDetailView(newsItem: item),
                            label: {
                                NewsView(data: item)
                            })
                        Divider()
                    }
                }
            }
        }
    }
}

#Preview {
    let items: [NewsItem] = [NewsItem.sample, NewsItem.sample, NewsItem.sample, NewsItem.sample, NewsItem.sample]
    CategoryView(news: Binding.constant(items), title: "Title")
}
