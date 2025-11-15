//
//  ArticleQuoteView.swift
//  NewsRSSReader
//
//  Created on 2025-11-14.
//

import SwiftUI

/// View для отображения цитаты с автором
struct ArticleQuoteView: View {
    let text: String
    let authorName: String
    let authorDescription: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Текст цитаты
            HStack(alignment: .top, spacing: 8) {
                // Кавычки
                Text("«")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color("Red"))
                    .offset(y: -8)

                Text(text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("Black"))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Автор цитаты
            VStack(alignment: .leading, spacing: 2) {
                if !authorName.isEmpty {
                    Text(authorName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("Black"))
                }

                if let description = authorDescription, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(Color("Gray"))
                }
            }
        }
        .padding(16)
        .background(
            Color("LigthGrey").opacity(0.3)
        )
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    VStack(spacing: 20) {
        ArticleQuoteView(
            text: "Тренды меняются. Распространению моды на естественность способствуют усталость, желание освободить время для более важных вещей...",
            authorName: "Мария Магдалена Тункара",
            authorDescription: "автор блога о расизме, феминизме и принятии себя"
        )

        ArticleQuoteView(
            text: "Важная цитата без описания автора",
            authorName: "Иван Иванов",
            authorDescription: nil
        )
    }
    .background(Color("Background"))
}
