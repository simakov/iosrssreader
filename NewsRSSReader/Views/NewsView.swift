//
//  NewsView.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 29.09.2024.
//
import SwiftUI
import SDWebImageSwiftUI

struct NewsView: View {
    @State var data: NewsItem
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
            if let image = data.image, let url = URL(string: image) {
                WebImage(url: url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                .frame(width: 60, height: 60)
                    .cornerRadius(4)
            } else {
                Rectangle()
                    .frame(width: 60, height: 60)
                    .cornerRadius(4)
            }
            
        }.padding(10)
    }
}

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView(data: NewsItem.sample)
    }
}

