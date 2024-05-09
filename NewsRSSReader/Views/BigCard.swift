//
//  BigCard.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 20.09.2023.
//

import SwiftUI
import FeedKit

struct BigCard: View {
    let news: RSSFeedItem
    let showTime: Bool
    init(_ news: RSSFeedItem, showTime: Bool) {
        self.news = news
        self.showTime = showTime
    }
    var body: some View {
        VStack{
            Image("background")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
            
            Text(news.title ?? "")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("Black"))
                    .padding(.horizontal)
                    .padding(.bottom, 1)
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
                
                .padding(.leading, 17)
                    .padding(.bottom, 10)
            
        }.background(Color("BackgroundWhite"))
    }
}
