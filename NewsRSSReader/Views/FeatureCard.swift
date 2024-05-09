//
//  FeatureCard.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 20.09.2023.
//

import SwiftUI
import FeedKit

struct FeatureCard: View {
    let news: RSSFeedItem
    let showTime: Bool
    init(_ news: RSSFeedItem, showTime: Bool) {
        self.news = news
        self.showTime = showTime
    }
    var body: some View {
        VStack{
            Spacer()
            Text(news.title ?? "")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color("White"))
                .clipped()
                .padding(.bottom, 5)
            HStack{
                Text(showTime ? "13:01": "Сегодня")
                    .font(.system(size: 13))
                    .foregroundColor(Color("Gray"))
                    .padding(.trailing, 5)
                    .padding(.leading, 5)
                if let category = news.categories {
                    Text(category.first!.value!)
                        .font(.system(size: 13))
                        .foregroundColor(Color("Gray"))
                }
                Spacer()
            }
        }
        .padding()
        .background(
        Image("background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .modifier(FadeDownViewModifier())
        )
        .frame(height: 350)
        .clipped()
    }
}
