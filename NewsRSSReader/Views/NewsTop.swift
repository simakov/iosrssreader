//
//  NewsTop.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 29.09.2024.
//
import SwiftUI
import SDWebImageSwiftUI

struct NewsTop: View {
    @Binding var data: NewsItem
    var body: some View {
        if let url = data.link, let linkUrl = URL(string: url), let image = data.image, let imageUrl = URL(string: image) {
            VStack{
                Spacer()
                NavigationLink(
                    destination: ArticleDetailView(newsItem: data),
                    label: {
                        Text(data.title ?? "")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("White"))
                            .clipped()
                            .padding(.bottom, 5)
                            .padding(.leading, 5)
                            .multilineTextAlignment(.leading)
                    })
                HStack{
                    Text(data.publishedDate())
                        .font(.system(size: 13))
                        .foregroundColor(Color("LigthGrey"))
                        .padding(.trailing, 5)
                        .padding(.leading, 5)
                    if let category = data.categories {
                        Text(category.first!)
                            .font(.system(size: 13))
                            .foregroundColor(Color("LigthGrey"))
                    }
                    Spacer()
                }
            }.padding()
                .background(
                    WebImage(url: imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(FadeDownViewModifier())
                )
                .frame(height: 350)
                .clipped()
        }
    }
}

struct NewsTop_Previews: PreviewProvider {
    static var previews: some View {
        NewsTop(data: Binding.constant(NewsItem.sample))
    }
}
