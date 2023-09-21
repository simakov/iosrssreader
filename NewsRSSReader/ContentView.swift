//
//  ContentView.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 14.09.2023.
//

import SwiftUI

struct ContentView: View {
    @State var tab = 0
    @State var latestNews: News = News(guid: "https://lenta.ru/news/2023/09/20/izmeneniya/",
                                       author: "Варвара Кошечкина", title: "Песков предупредил о происходящих в мире тектонических изменениях",
                                       link: "https://lenta.ru/news/2023/09/20/izmeneniya/",
                                       description: "<![CDATA[В мире происходят тектонические изменения. Организация Объединенных наций (ООН) должна к ним адаптироваться. Об этом предупредил пресс-секретарь президента России Дмитрий Песков.]]>",
                                       pubDate: "Wed, 20 Sep 2023 16:38:29 +0300",
                                       enclosure: "https://icdn.lenta.ru/images/2023/09/20/16/20230920163731575/pic_e8e6cfaf91098f77b5efec4625e837ff.jpg",
                                       category: "Мир")
    
    var body: some View {
        VStack(spacing: 0) {
            TopPanel()
            ScrollView(.vertical) {
               FeatureCard(latestNews, showTime: true)
                HStack(alignment: .center,spacing: 20) {
                    if tab == 0 {
                        Text("Последнее")
                            .modifier(SelectedTabModifier())
                        Button {
                            tab = 1
                        } label: {
                            Text("Главное")
                                .padding(8)
                        }
                    } else {
                        Button {
                            tab = 0
                        } label: {
                            Text("Последнее")
                                .padding(8)
                        }
                        Text("Главное")
                            .modifier(SelectedTabModifier())
                    }
                    
                }.padding()
                    .font(.system(size: 15))
                    .textCase(.uppercase)
                    .foregroundColor(Color("Black"))
                VStack(spacing: 20) {
                    ForEach(0..<10, id: \.self) { num in
                        NewsItem()
                    }
                }
                
                Text("Больше новостей")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("Black"))
                    .textCase(.uppercase)
                    .padding(.top, 7)
                    .padding(.bottom, 7)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    .border(Color("LigthGrey"))
                    .padding(.top,10)
                FeatureCard(latestNews, showTime: false).padding()
                BigCard(latestNews, showTime: false).padding()
            }
            Spacer() 
        }
    }
}
struct SelectedTabModifier: ViewModifier{
    func body(content: Content) -> some View {
           return content
            .padding(8)
            .background(Color("LigthGrey"))
            .cornerRadius(17)
       }
}

struct FadeDownViewModifier: ViewModifier{
    func body(content: Content) -> some View {
           return content
                .overlay(
                LinearGradient(gradient: Gradient(colors: [.clear, Color("Black")]),
                                   startPoint: .center,
                                   endPoint: .bottom)
                )
       }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
