//
//  Home.swift
//  RssReader
//

import SwiftUI
import SDWebImage
import FeedKit
import SDWebImageSwiftUI

struct Home: View {
    let itemOnPage:Int = 10
    @StateObject var viewModel: HomeViewModel
    var body: some View {
        if let firstNews = viewModel.firstNews {
            NewsTop(data: Binding.constant(firstNews))
                .id(0)
        }
        NewsTabs(tab: $viewModel.tab)
        LazyVStack(alignment: .leading) {
            if viewModel.rssFeed.count == 0 {
                ForEach(0..<7) { _ in
                    NewsView(data: NewsItem.sample)
                        .redacted(reason: .placeholder)
                        .shimmering()
                }
            } else {
                ForEach(viewModel.rssFeed) { item in
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

struct FadeDownViewModifier: ViewModifier{
    func body(content: Content) -> some View {
        return content
            .overlay(
                LinearGradient(gradient: Gradient(colors: [.clear, Color("Background")]),
                               startPoint: .center,
                               endPoint: .bottom)
            )
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home(viewModel: HomeViewModel(prewiew: true))
    }
}
