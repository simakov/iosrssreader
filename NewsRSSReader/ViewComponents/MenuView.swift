//
//  MenuView.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 03.11.2024.
//

import SwiftUI

struct MenuView: View {
    @Binding var menuShow: Bool
    var categories: [String]
    @Binding var selectedCategory: String
    var body: some View {
        VStack{
            HStack {
                Button(action: {
                    withAnimation {
                        menuShow.toggle()
                    }
                }, label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(Color("White"))
                })
                .padding(.leading, 20)
                Spacer()
            }
            Divider()
                .background(Color("Gray"))
                .padding(.vertical, 10)
            MenuItem(title: "Главная", selected: selectedCategory.isEmpty)
                .onTapGesture {
                    selectedCategory = ""
                    withAnimation {
                        menuShow.toggle()
                    }
                }
                .padding(.bottom, 4)
            ForEach(categories, id: \.self) { category in
                MenuItem(title: category, selected: category == selectedCategory)
                    .onTapGesture {
                        selectedCategory = category
                        menuShow.toggle()
                    }
                    .padding(.bottom, 4)
            }
            Spacer()
        }
        .background(Color("Background"))
        .padding(.top, 20)
    }
}

struct MenuItem: View {
    var title: String
    var selected: Bool
    var body: some View {
        if selected {
            HStack{
                Rectangle()
                    .frame(width: 3, height: 20)
                    .foregroundColor(Color("Red"))
                Text(title)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundColor(Color("Red"))
                    .padding(.leading, 5)
                Spacer()
            }
        } else {
            HStack{
                Rectangle()
                    .frame(width: 3, height: 20)
                    .foregroundColor(Color("Background"))
                Text(title)
                    .foregroundColor(Color("White"))
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.leading, 5)
                Spacer()
            }
        }
    }
}


struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        let categories: [String] = ["Мир", "Спорт", "Наука"]
        MenuView(menuShow: .constant(true), categories: categories, selectedCategory: .constant(""))
    }
}
