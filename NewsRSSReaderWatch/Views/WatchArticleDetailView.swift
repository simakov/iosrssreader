//
//  WatchArticleDetailView.swift
//  NewsRSSReaderWatch
//
//  Article detail view with native HTML parsing
//

import SwiftUI
import NewsRSSReaderShared

struct WatchArticleDetailView: View {
    let newsItem: NewsItem

    @State private var articleContent: ArticleContent?
    @State private var isLoading = true
    @State private var error: Error?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Title
                Text(newsItem.title ?? "")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    .padding(.bottom, 6)

                // Date
                Text(newsItem.publishedDate())
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)

                // Main image
                if let imageUrl = newsItem.image {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.bottom, 8)
                }

                // Content
                if isLoading {
                    ProgressView()
                        .padding()
                } else if let error = error {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 24))
                            .foregroundColor(Color("Gray"))
                        Text("Loading error")
                            .font(.system(size: 12))
                            .foregroundColor(Color("Gray"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else if let content = articleContent {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(content.content.enumerated()), id: \.offset) { _, item in
                            renderContentItem(item)
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadArticle()
        }
    }

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
        case .relatedMaterial:
            EmptyView()
        }
    }

    private func loadArticle() {
        guard let articleUrl = newsItem.link else {
            self.error = NSError(domain: "WatchArticleDetailView", code: -1)
            self.isLoading = false
            return
        }

        ArticleLoaderService.shared.loadArticle(url: articleUrl) { result in
            switch result {
            case .success(let html):
                if let parsedContent = LentaArticleParser.shared.parse(html: html, existingNewsItem: newsItem) {
                    self.articleContent = parsedContent
                    self.isLoading = false
                } else {
                    self.error = NSError(domain: "WatchArticleDetailView", code: -2)
                    self.isLoading = false
                }
            case .failure(let loaderError):
                self.error = loaderError
                self.isLoading = false
            }
        }
    }
}

#Preview {
    NavigationView {
        WatchArticleDetailView(newsItem: NewsItem.sample)
    }
}
