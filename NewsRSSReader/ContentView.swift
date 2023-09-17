//
//  ContentView.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 14.09.2023.
//

import SwiftUI

struct ContentView: View {
    @State var tab = 0
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
            ScrollView(.vertical) {
                VStack{
                    Spacer()
                    Text("Китай обнародовал план по углублению интеграции с Тайванем")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color("White"))
                        .clipped()
                        .padding(.bottom, 5)
                    HStack{
                        Text("13:01")
                            .font(.system(size: 13))
                            .foregroundColor(Color("Gray"))
                            .padding(.trailing, 5)
                            .padding(.leading, 5)
                        Text("Мир")
                            .font(.system(size: 13))
                            .foregroundColor(Color("Gray"))
                        Spacer()
                    }
                }.padding()
                    .background(
                        Image("background")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .modifier(FadeDownViewModifier())
                    )
                    .frame(height: 350)
                    .clipped()
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
                ForEach(0..<10, id: \.self) { num in
                    HStack(spacing: 10) {
                        VStack(alignment: .leading) {
                            Text("В российском фитнес-центре дети отравились парами хлора")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color.black)
                                .padding(.bottom, 5)
                                .multilineTextAlignment(.leading)
                            Text("12:00")
                                .font(.system(size: 13, design: .serif))
                                .foregroundColor(Color("Gray"))
                        }
                        Image("newsItem")
                            .frame(width: 60, height: 60)
                            .scaledToFit()
                            .cornerRadius(4)
                    }.padding(10)
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
