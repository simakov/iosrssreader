//
//  ContentView.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 14.09.2023.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct ContentView: View {
    @State var shouldScrollToTop = false
    @State var menuShow = false
    @StateObject var homeViewModel = HomeViewModel()
    var body: some View {
        if menuShow {
            ZStack{
                MenuView(menuShow: $menuShow, categories: homeViewModel.categories, selectedCategory: $homeViewModel.selectedCategory)
                Spacer()
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("Background"))
        } else {
            NavigationView {
                VStack(spacing: 0) {
                    HStack{
                        Button(action: {
                            withAnimation {
                                menuShow.toggle()
                            }
                        }, label: {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(Color("White"))
                                .padding(10)
                        })
                        Image("logo")
                            .resizable()
                            .frame(width: 120.0, height: 20.0)
                            .padding(10)
                            .onTapGesture {
                                withAnimation {
                                    shouldScrollToTop.toggle()
                                }
                            }
                        Spacer()
                            .onTapGesture {
                                withAnimation {
                                    shouldScrollToTop.toggle()
                                }
                            }
                    }.background(Color("Background"))
                    
                    
                    if !homeViewModel.selectedCategory.isEmpty {
                        ScrollViewReader { proxy in
                            ScrollView(.vertical) {
                                CategoryView(news: $homeViewModel.categoryFeed, title: homeViewModel.categories[homeViewModel.selectedCategory] ?? homeViewModel.selectedCategory)
                                    .onChange(of: shouldScrollToTop) { value in
                                        proxy.scrollTo(0, anchor: .top)
                                    }
                                Spacer()
                            }
                        }
                    } else {
                        ScrollViewReader { proxy in
                            ScrollView(.vertical) {
                                Home(viewModel: homeViewModel)
                                    .onChange(of: shouldScrollToTop) { value in
                                        proxy.scrollTo(0, anchor: .top)
                                    }
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
