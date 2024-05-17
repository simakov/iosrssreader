//
//  Home.swift
//  RssReader
//
//  Created by Tomoyuki Murakami on 2021/01/08.
//  Copyright © 2021 tomoyukim. All rights reserved.
//

import SwiftUI
import SDWebImage
import FeedKit
import SDWebImageSwiftUI

struct Home: View {
    @StateObject public var viewModel: HomeViewModel
    var body: some View {
        if viewModel.isLoading {
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.gray)
                .offset(x: 0, y: -200)
                .navigationBarTitle("", displayMode: .inline)
        } else {
            
            if let first = viewModel.firstNews  {
                NewsTopView(data: first)
            }
            //            NewsTabs()
            ForEach(viewModel.rssFeed) { item in
                if (item.link != nil) {
                    NavigationLink(
                        destination: DetailNewsView(.init(from: item)),
                        label: {
                            NewsView(data: item)
                            
                        })
                }
                Divider()
            }
            Button {
                self.viewModel.addMore()
            }
        label: {
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
        }
    }
}



//
//struct Home_Previews: PreviewProvider {
//    static var previews: some View {
//        Home()
//    }
//}
