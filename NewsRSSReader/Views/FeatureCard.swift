//
//  FeatureCard.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 20.09.2023.
//

import SwiftUI

struct FeatureCard: View {
    let news: News
    let showTime: Bool
    init(_ news: News, showTime: Bool) {
        self.news = news
        self.showTime = showTime
    }
    var body: some View {
        VStack{
            Spacer()
            Text(news.title)
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
                Text(news.category)
                    .font(.system(size: 13))
                    .foregroundColor(Color("Gray"))
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

struct FeatureCard_Previews: PreviewProvider {
    static var previews: some View {
        FeatureCard(News(guid: "https://lenta.ru/news/2023/09/20/izmeneniya/",
                         author: "Варвара Кошечкина", title: "Песков предупредил о происходящих в мире тектонических изменениях",
                         link: "https://lenta.ru/news/2023/09/20/izmeneniya/",
                         description: "<![CDATA[В мире происходят тектонические изменения. Организация Объединенных наций (ООН) должна к ним адаптироваться. Об этом предупредил пресс-секретарь президента России Дмитрий Песков.]]>",
                         pubDate: "Wed, 20 Sep 2023 16:38:29 +0300",
                         enclosure: "https://icdn.lenta.ru/images/2023/09/20/16/20230920163731575/pic_e8e6cfaf91098f77b5efec4625e837ff.jpg",
                         category: "Мир"), showTime: true)
    }
}
