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
                }.background(Color("Background"))
                ScrollView(.vertical) {
                    Home()
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
