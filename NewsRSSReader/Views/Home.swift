//
//  Home.swift
//  RssReader
//
//  Created by Tomoyuki Murakami on 2021/01/08.
//  Copyright © 2021 tomoyukim. All rights reserved.
//

import SwiftUI
import SDWebImage
import FeedKit
import SDWebImageSwiftUI

struct Home: View {
    @StateObject private var viewModel: HomeViewModel = .init("https://lenta.ru/rss")
    var body: some View {
        if viewModel.isLoading {
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.gray)
                .offset(x: 0, y: -200)
                .navigationBarTitle("", displayMode: .inline)
        } else {
            
            if let first = viewModel.firstNews  {
                NewsTop(data: first)
            }
//            NewsTabs()
            ForEach(viewModel.rssFeed) { item in
                if let link = item.link {
                    NavigationLink(
                        destination: WebView(URL(string: link)!),
                        label: {
                            NewsView(data: item)
                            
                        })
                }
                Divider()
            }
            Button {
                self.viewModel.addMore()
            }
        label: {
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
        }
        }
        //
        //                ScrollView() {
        //                    LazyVStack(alignment: .leading) {
        //                        /* Section
        //                        HStack {
        //                            Text("Today")
        //                                .font(.subheadline)
        //                                .fontWeight(.regular)
        //                                .foregroundColor(.blue)
        //                                .padding(.horizontal)
        //                                .padding(.vertical, 6)
        //                            Spacer()
        //                        }
        //                        */
        //                        ForEach(viewModel.articleCardInput) { input in
        //                            NavigationLink(
        //                                destination: WebView(url: URL(string: input.urlString)!),
        //                                label: {
        //                                    ArticleCard(input: input)
        //                                })
        //                            Divider()
        //                        }
        //                    }
        //                }
        //
        //            }
        //  } .navigationBarTitle("Timeline", displayMode: .inline)
    }
}

struct NewsTabs: View {
    @State var tab = 0
    init(tab: Int = 0) {
        self.tab = tab
    }
    var body: some View {
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
        
    }
}
struct NewsTop: View {
    @State var data: RSSFeedItem
    var body: some View {
        if let enclosure = data.enclosure, let url = enclosure.attributes?.url {
            VStack{
                Spacer()
                Text(data.title ?? "")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("White"))
                    .clipped()
                    .padding(.bottom, 5)
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
struct NewsView: View {
    @State var data: RSSFeedItem
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading) {
                if let title = data.title {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.black)
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
                        .frame(width: 60, height: 60)
                        .scaledToFit()
                        .cornerRadius(4)
                }
            }
        }.padding(10)
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

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
