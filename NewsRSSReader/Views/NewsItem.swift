//
//  NewsItem.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 19.09.2023.
//

import SwiftUI

struct NewsItem: View {
    var body: some View {
        HStack(spacing: 10){
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
            
        }
        
    }
}

struct NewsItem_Previews: PreviewProvider {
    static var previews: some View {
        NewsItem()
    }
}
