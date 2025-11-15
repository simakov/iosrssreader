//
//  ArticleSubheadingView.swift
//  NewsRSSReader
//
//  Created on 2025-11-14.
//

import SwiftUI

/// View для отображения подзаголовка
struct ArticleSubheadingView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color("Black"))
            .lineSpacing(4)
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 8)
    }
}

#Preview {
    VStack(spacing: 16) {
        ArticleSubheadingView(text: "Нереальная красота")
        ArticleSubheadingView(text: "«Жить в мире, где твое тело считается образцом мерзости, довольно тяжело»")
    }
    .background(Color("Background"))
}
