//
//  NewsTopView.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 17.05.2024.
//

import SwiftUI
import FeedKit
import SDWebImageSwiftUI
import NewsRSSReaderShared

struct NewsTopView: View {
    @State var data: RSSFeedItem
    var body: some View {
        if let enclosure = data.enclosure, let url = enclosure.attributes?.url {
            VStack(alignment: .leading) {
                Spacer()
                    NavigationLink(
                        destination: ArticleDetailView(newsItem: NewsItem(from: data)),
                        label: {
                            Text(data.title ?? "")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color("White"))
                                .clipped()
                                .multilineTextAlignment(.leading)
                                .padding(.bottom, 5)
                                .padding(.horizontal, 5)
                        })
                
                HStack{
                    Text(data.publishedDate())
                        .font(.system(size: 13))
                        .foregroundColor(Color("Gray"))
                        .padding(.trailing, 5)
                        .padding(.leading, 5)
                    if let category = data.categories {
                        Text(category.first!.value!)
                            .font(.system(size: 13))
                            .foregroundColor(Color("Gray"))
                    }
                    Spacer()
                }
            }.padding()
                .background(
                    
                    WebImage(url: URL(string: url))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(FadeDownViewModifier())
                    
                )
                .frame(height: 350)
                .clipped()
        }
    }
}
#Preview {
    NewsTopView(data: RSSFeedItem.sample())
}
