//
//  ContentView.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 14.09.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
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
            }.background(Color("Black"))
            
            VStack{
                Spacer()
                Text("Китай обнародовал план по углублению интеграции с Тайванем")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("White"))
                    .clipped()
                HStack{
                    Text("13:01")
                        .font(.system(size: 15))
                        .foregroundColor(Color("Gray"))
                        .padding(.trailing, 10)
                    Text("Мир")
                        .font(.system(size: 15))
                        .foregroundColor(Color("Gray"))
                    Spacer()
                }.padding()
            }
            .background(
                 Image("background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .modifier(FadeDownViewModifier())
            )
            .frame(height: 350)
            .clipped()
            //.fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
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
