//
//  ArticleInfoBoxView.swift
//  NewsRSSReader
//
//  Created on 2025-11-14.
//

import SwiftUI

/// View для отображения выделенного информационного блока
struct ArticleInfoBoxView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Волна сверху
            Rectangle()
                .fill(Color("Red"))
                .frame(height: 3)

            // Текст
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("Black"))
                .lineSpacing(4)
                .padding(16)

            // Волна снизу
            Rectangle()
                .fill(Color("Red"))
                .frame(height: 3)
        }
        .background(Color("LigthGrey").opacity(0.2))
        .cornerRadius(4)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    VStack(spacing: 20) {
        ArticleInfoBoxView(
            text: "У детей, которые активно используют соцсети, наблюдается снижение удовлетворенности жизнью и повышение уровня тревожности."
        )

        ArticleInfoBoxView(
            text: "Важная информация: это выделенный блок с особо значимыми данными, которые требуют внимания читателя."
        )
    }
    .background(Color("Background"))
}
