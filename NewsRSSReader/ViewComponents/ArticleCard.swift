//
//  ArticleCard.swift
//  RssReader
//
//  Created by Tomoyuki Murakami on 2021/01/08.
//  Copyright © 2021 tomoyukim. All rights reserved.
//

import SwiftUI

extension ArticleCard.Input {
    func parseDate(_ date: String) -> Date {
        // TODO: this converter should be exeuted at response parser
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return RFC3339DateFormatter.date(from: date)!
    }
    
    func formattedDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

struct ArticleCard: View {
    struct Input: Identifiable {
        let id: UUID = UUID()
        let title: String
        let image: UIImage
        let summary: String
        let date: String
        let urlString: String
        let feedTitle: String
    }
        
    let input: Input
    
    init(input: Input) {
        self.input = input
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack() {
                    Image(uiImage: UIImage(systemName: "pencil.tip.crop.circle")!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 14, height: 14)
                        .clipShape(Circle())
                    Text(input.feedTitle)
                        .foregroundColor(.black)
                        .font(.caption)
                }
                Text(input.title)
                    .foregroundColor(.black)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .padding(.vertical, 2)
                let str = input.formattedDate(date: input.parseDate(input.date), format: "yyyy/MM/dd")
                Text(str)
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .fontWeight(.light)
            }
            Spacer()
            Image(uiImage: input.image)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal)
    }}

/*
struct ArticleCard_BigImage: View {
    struct Input: Identifiable {
        let id: UUID = UUID()
        let title: String
        let image: UIImage
        let summary: String
        let date: String
    }
        
    let input: Input
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(uiImage: input.image)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipShape(Rectangle())
            Text(input.title)
                .foregroundColor(.black)
                .font(.headline)
                .fontWeight(.medium)
                .padding(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 2))
            Text(input.summary)
                .foregroundColor(.black)
                .font(.body)
                .fontWeight(.light)
                .lineLimit(2)
                .padding(EdgeInsets(top: 0, leading: 6, bottom: 2, trailing: 2))
            HStack(alignment: .top) {
                let str = input.formattedDate(date: input.parseDate(input.date), format: "yyyy/MM/dd")
                Text(str)
                    .foregroundColor(.gray)
                    .font(.footnote)
                Spacer()
                Text("tomoyukim's blog")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
            .padding(.horizontal, 6)
        }
    }
}
*/

struct ArticleCard_Previews: PreviewProvider {
    static var previews: some View {
        ArticleCard(input: .init(title: "Mac OSでexec-path-from-shellをEmacsで使いつつ、ターミナルでfishを使う", image: UIImage(named: "coverImage")!, summary: "fishはPOSIX非互換シェルのため、rbenv などがうまく動かなかったり、Bashスクリプトによる初期化がうまく引き継げないなどの問題がおきることがあります。 環境によりますが、PATH他の環境をfishに移行するのも面倒なので、とりあえずArch Linuxの方法を採用しておけば楽でよさそうです。 fish - ArchWiki 一方Mac OS環境ではEmacsをGUI起動するにあたって、exec-path-from-shell という素晴らしいパッケージを利用していることがあります。 github.com そのため、SHELLはBashだけどfishが実行されちゃって、以下のような…", date: "2020-09-14T22:57:01+09:00", urlString: "http://localhost", feedTitle: "tomoyukim's blog")).previewLayout(.sizeThatFits)

//        ArticleCard()
    }
}
