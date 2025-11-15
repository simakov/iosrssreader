//
//  ArticleAuthorView.swift
//  NewsRSSReader
//
//  Created on 2025-11-14.
//

import SwiftUI
import SDWebImageSwiftUI

/// View для отображения информации об авторе статьи
struct ArticleAuthorView: View {
    let name: String
    let photo: String?
    let jobTitle: String?

    var body: some View {
        HStack(spacing: 12) {
            // Фото автора
            if let photoUrl = photo, let url = URL(string: photoUrl) {
                WebImage(url: url)
                    .resizable()
                    .indicator(.activity)
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .background(
                        Circle()
                            .fill(Color("Gray").opacity(0.2))
                    )
            } else {
                // Placeholder если нет фото
                Circle()
                    .fill(Color("Gray").opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(Color("Gray"))
                    )
            }

            // Имя и должность автора
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("Black"))

                if let title = jobTitle, !title.isEmpty {
                    Text(title)
                        .font(.system(size: 14))
                        .foregroundColor(Color("Gray"))
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("LigthGrey").opacity(0.2))
    }
}

#Preview {
    VStack(spacing: 16) {
        ArticleAuthorView(
            name: "Анна Смирнова",
            photo: "https://icdn.lenta.ru/images/2024/11/14/12/portrait_256.jpg",
            jobTitle: "Специальный корреспондент"
        )

        ArticleAuthorView(
            name: "Иван Петров",
            photo: nil,
            jobTitle: "Обозреватель отдела экономики"
        )

        ArticleAuthorView(
            name: "Мария Иванова",
            photo: nil,
            jobTitle: nil
        )
    }
    .background(Color("Background"))
}
