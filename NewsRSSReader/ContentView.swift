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
    @StateObject private var viewModel: HomeViewModel = .init("https://lenta.ru/rss")
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack{
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(Color("White"))
                        .padding(10)
                    
                    Image("logo")
                        .resizable()
                        .frame(width: 120.0, height: 20.0)
                        .padding(10)
                    
                    Spacer()
                    Button(action: {
                        viewModel.load()
                    }, label: {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .foregroundColor(Color("White"))
                            .frame(width: 15.0, height: 15.0)
                            .padding(10)
                    })
                    
                }.background(Color("Background"))
                ScrollView(.vertical) {
                    Home(viewModel: viewModel)
                    Spacer()
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
