//
//  NewsItem.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 19.09.2023.
//

import SwiftUI
import FeedKit
import SDWebImageSwiftUI

struct NewsView: View {
    @State var data: RSSFeedItem
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading) {
                if let title = data.title {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("Black"))
                        .padding(.bottom, 5)
                        .multilineTextAlignment(.leading)
                }
                
                Text(data.publishedDate())
                    .font(.system(size: 13))
                    .foregroundColor(Color("Gray"))
            }
            Spacer()
            if let enclosure = data.enclosure {
                if let url = enclosure.attributes?.url {
                    WebImage(url: URL(string: url)!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(4)
                }
            }
        }.padding(10)
    }
}

struct NewsItem_Previews: PreviewProvider {
    static var previews: some View {
        NewsView(data: RSSFeedItem.sample())
    }
}
