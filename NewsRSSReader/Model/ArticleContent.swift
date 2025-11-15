//
//  ArticleContent.swift
//  NewsRSSReader
//
//  Created on 2025-11-14.
//

import Foundation

/// Типы контента статьи для нативного отображения
enum ArticleContentType {
    /// Текстовый параграф
    case paragraph(text: String, isLead: Bool = false)

    /// Подзаголовок (h2)
    case subheading(text: String)

    /// Изображение с подписью и авторством
    case image(url: String, caption: String?, credit: String?)

    /// Цитата с автором
    case quote(text: String, authorName: String, authorDescription: String?)

    /// Информация об авторе статьи
    case author(name: String, photo: String?, jobTitle: String?)

    /// Выделенный информационный блок
    case infoBox(text: String)

    /// Связанные материалы (парсим, но пока не показываем)
    case relatedMaterial(title: String, description: String?, imageUrl: String?, articleUrl: String, date: String?)
}

/// Модель контента статьи после парсинга HTML
struct ArticleContent {
    /// Заголовок статьи
    let title: String

    /// URL главного изображения
    let image: String?

    /// Дата публикации
    let publishedDate: Date?

    /// Категория статьи
    let category: String?

    /// Массив элементов контента
    let content: [ArticleContentType]

    init(title: String, image: String?, publishedDate: Date?, category: String?, content: [ArticleContentType]) {
        self.title = title
        self.image = image
        self.publishedDate = publishedDate
        self.category = category
        self.content = content
    }
}
