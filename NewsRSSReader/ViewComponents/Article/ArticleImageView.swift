//
//  ArticleImageView.swift
//  NewsRSSReader
//
//  Created on 2025-11-14.
//

import SwiftUI
import SDWebImageSwiftUI

/// View для отображения изображения с подписью и авторством
struct ArticleImageView: View {
    let url: String
    let caption: String?
    let credit: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Изображение
            WebImage(url: URL(string: url))
                .resizable()
                .indicator(.activity)
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .background(Color("Gray").opacity(0.2))

            // Подпись и/или авторство
            VStack(alignment: .leading, spacing: 4) {
                if let caption = caption, !caption.isEmpty {
                    Text(caption)
                        .font(.system(size: 14))
                        .foregroundColor(Color("Gray"))
                }

                if let credit = credit, !credit.isEmpty {
                    Text(credit)
                        .font(.system(size: 12))
                        .foregroundColor(Color("Gray"))
                        .italic()
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    VStack(spacing: 20) {
        ArticleImageView(
            url: "https://icdn.lenta.ru/images/2024/11/14/12/20241114121234567/owl_wide_1280_720.jpg",
            caption: "Описание изображения",
            credit: "Фото: Иван Иванов / РИА Новости"
        )

        ArticleImageView(
            url: "https://icdn.lenta.ru/images/2024/11/14/12/20241114121234567/owl_wide_1280_720.jpg",
            caption: nil,
            credit: "Фото: Getty Images"
        )
    }
    .background(Color("Background"))
}
