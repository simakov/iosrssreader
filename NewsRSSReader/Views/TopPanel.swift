//
//  TopPanel.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 20.09.2023.
//

import SwiftUI

struct TopPanel: View {
    var body: some View {
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
    }
}

struct TopPanel_Previews: PreviewProvider {
    static var previews: some View {
        TopPanel()
    }
}
