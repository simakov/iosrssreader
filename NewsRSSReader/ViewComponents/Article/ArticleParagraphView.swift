//
//  ArticleParagraphView.swift
//  NewsRSSReader
//
//  Created on 2025-11-14.
//

import SwiftUI

/// View для отображения параграфа текста
struct ArticleParagraphView: View {
    let text: String
    let isLead: Bool

    var body: some View {
        Text(text)
            .font(isLead ? .system(size: 17, weight: .medium) : .system(size: 16))
            .foregroundColor(Color("Black"))
            .lineSpacing(4)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 16) {
        ArticleParagraphView(
            text: "Это лидирующий параграф статьи, который выделяется полужирным шрифтом и немного большим размером.",
            isLead: true
        )

        ArticleParagraphView(
            text: "Это обычный параграф текста статьи. Он содержит основную информацию и выводится стандартным шрифтом.",
            isLead: false
        )
    }
    .background(Color("BlackInversed"))
}
