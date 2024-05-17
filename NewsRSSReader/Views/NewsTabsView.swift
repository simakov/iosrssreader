//
//  NewsTabsView.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 17.05.2024.
//

import SwiftUI

struct NewsTabsView: View {
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

#Preview {
    NewsTabsView()
}
