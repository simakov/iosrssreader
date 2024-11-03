//
//  NewsTabs.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 29.09.2024.
//
import SwiftUI

struct NewsTabs: View {
    @Binding var tab: Int
    var tabs: [String] = ["Главное", "Последнее", "Все"]
    var body: some View {
        HStack(alignment: .center,spacing: 20) {
            ForEach(0..<tabs.count, id: \.self) { index in
                if tab == index {
                    Text(tabs[index])
                        .padding(8)
                        .background(Color("LigthGrey"))
                        .foregroundColor(Color("Background"))
                        .cornerRadius(17)
                        .onTapGesture {
                            tab = index
                        }
                } else {
                    Text(tabs[index]).onTapGesture {
                        tab = index
                    }
                    .foregroundColor(Color("Black"))
                }
                    
            }
        }.padding()
            .font(.system(size: 15))
            .textCase(.uppercase)
        
    }
}

struct NewsTab_previews: PreviewProvider {
    static var previews: some View {
        NewsTabs(tab: .constant(0))
    }
}
