//
//  ArticleDetailView.swift
//  NewsRSSReader
//
//  Created on 2025-11-14.
//

import SwiftUI
import SDWebImageSwiftUI

/// View для отображения полной статьи с нативным рендерингом контента
struct ArticleDetailView: View {
    let newsItem: NewsItem

    @State private var articleContent: ArticleContent?
    @State private var isLoading = true
    @State private var error: Error?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Заголовок статьи (из RSS feed)
                Text(newsItem.title ?? "")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("Black"))
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                // Дата публикации
                Text(newsItem.publishedDate())
                    .font(.system(size: 13))
                    .foregroundColor(Color("Gray"))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                // Главное изображение (из RSS feed)
                if let imageUrl = newsItem.image {
                    WebImage(url: URL(string: imageUrl))
                        .resizable()
                        .indicator(.activity)
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .background(Color("Gray").opacity(0.2))
                        .padding(.bottom, 16)
                }

                // Контент статьи или shimmer при загрузке
                if isLoading {
                    // Shimmer placeholder для параграфов
                    VStack(spacing: 12) {
                        ForEach(0..<5, id: \.self) { _ in
                            ShimmerParagraphPlaceholder()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                } else if let error = error {
                    // Показываем ошибку
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(Color("Red"))

                        Text("Ошибка загрузки статьи")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("Black"))

                        Text(error.localizedDescription)
                            .font(.system(size: 14))
                            .foregroundColor(Color("Gray"))
                            .multilineTextAlignment(.center)
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity)
                } else if let content = articleContent {
                    // Рендерим parsed контент
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(content.content.enumerated()), id: \.offset) { index, item in
                            renderContentItem(item)
                        }
                    }
                }
            }
        }
        .background(Color("BlackInversed"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadArticle()
        }
    }

    // MARK: - Content Rendering

    /// Рендерит элемент контента в зависимости от его типа
    @ViewBuilder
    private func renderContentItem(_ item: ArticleContentType) -> some View {
        switch item {
        case .paragraph(let text, let isLead):
            ArticleParagraphView(text: text, isLead: isLead)

        case .subheading(let text):
            ArticleSubheadingView(text: text)

        case .image(let url, let caption, let credit):
            ArticleImageView(url: url, caption: caption, credit: credit)

        case .quote(let text, let authorName, let authorDescription):
            ArticleQuoteView(text: text, authorName: authorName, authorDescription: authorDescription)

        case .author(let name, let photo, let jobTitle):
            ArticleAuthorView(name: name, photo: photo, jobTitle: jobTitle)

        case .infoBox(let text):
            ArticleInfoBoxView(text: text)

        case .relatedMaterial(_, _, _, _, _):
            // Пока не показываем related materials
            EmptyView()
        }
    }

    // MARK: - Article Loading

    /// Загружает статью по URL
    private func loadArticle() {
        guard let articleUrl = newsItem.link else {
            self.error = NSError(
                domain: "ArticleDetailView",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "URL статьи отсутствует"]
            )
            self.isLoading = false
            return
        }

        // Загружаем HTML
        ArticleLoaderService.shared.loadArticle(url: articleUrl) { result in
            switch result {
            case .success(let html):
                // Парсим HTML
                if let parsedContent = LentaArticleParser.shared.parse(html: html, existingNewsItem: newsItem) {
                    self.articleContent = parsedContent
                    self.isLoading = false
                } else {
                    self.error = NSError(
                        domain: "ArticleDetailView",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Не удалось распарсить статью"]
                    )
                    self.isLoading = false
                }

            case .failure(let loaderError):
                self.error = loaderError
                self.isLoading = false
            }
        }
    }
}

// MARK: - Shimmer Placeholder

/// Placeholder для параграфа с shimmer эффектом
struct ShimmerParagraphPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(Color("Gray").opacity(0.3))
                .frame(height: 14)
                .cornerRadius(4)

            Rectangle()
                .fill(Color("Gray").opacity(0.3))
                .frame(height: 14)
                .cornerRadius(4)

            Rectangle()
                .fill(Color("Gray").opacity(0.3))
                .frame(width: 200, height: 14)
                .cornerRadius(4)
        }
        .shimmering()
    }
}

#Preview {
    NavigationView {
        ArticleDetailView(
            newsItem: NewsItem(
                title: "Пример заголовка новости для предпросмотра",
                summary: "Краткое описание",
                authors: nil,
                link: "https://lenta.ru/news/2024/11/14/example/",
                updated: nil,
                categories: nil,
                content: nil,
                published: Date(),
                source: nil,
                rights: nil,
                image: "https://icdn.lenta.ru/images/2024/11/14/12/owl_wide_1280_720.jpg"
            )
        )
    }
}
