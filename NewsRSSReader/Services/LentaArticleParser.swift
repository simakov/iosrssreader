//
//  LentaArticleParser.swift
//  NewsRSSReader
//
//  Created on 2025-11-14.
//

import Foundation
import SwiftSoup

/// Парсер HTML статей с сайта Lenta.ru
class LentaArticleParser {
    /// Singleton instance
    static let shared = LentaArticleParser()

    private init() {}

    /// Парсит HTML страницу статьи в структурированный контент
    /// - Parameters:
    ///   - html: HTML строка страницы
    ///   - existingNewsItem: Существующий NewsItem с данными из RSS (заголовок, изображение, дата)
    /// - Returns: ArticleContent или nil в случае ошибки парсинга
    func parse(html: String, existingNewsItem: NewsItem) -> ArticleContent? {
        do {
            let doc = try SwiftSoup.parse(html)

            // Парсим метаданные
            let metadata = parseMetadata(doc: doc)

            // Парсим автора отдельно (обычно перед телом статьи)
            var author: ArticleContentType? = nil
            if let authorBlock = try? doc.select(".topic-authors").first() {
                author = parseAuthor(element: authorBlock)
            }

            // Собираем контент
            var content: [ArticleContentType] = []

            // Добавляем автора в начало, если есть
            if let authorContent = author {
                content.append(authorContent)
            }

            // Пробуем найти контент в разных возможных контейнерах
            // Порядок попыток:
            // 1. .content-body (текущая структура Lenta.ru)
            // 2. .topic-body__content (старая структура)
            // 3. .topic-body (промежуточная структура)
            // 4. articleBody_ (самый общий контейнер)
            var body = try? doc.select(".content-body").first()
            if body == nil {
                body = try? doc.select(".topic-body__content").first()
            }
            if body == nil {
                body = try? doc.select(".topic-body").first()
            }
            if body == nil {
                body = try? doc.select("[id^=articleBody_]").first()
            }

            if let body = body {
                let children = body.children()

                for child in children {
                    if let contentItem = parseContentElement(element: child) {
                        content.append(contentItem)
                    }
                }
            }

            return ArticleContent(
                title: existingNewsItem.title ?? "",
                image: existingNewsItem.image,
                publishedDate: existingNewsItem.published ?? metadata.date,
                category: metadata.category,
                content: content
            )

        } catch {
            return nil
        }
    }

    // MARK: - Private Parsing Methods

    /// Парсит метаданные статьи (категория, дата)
    private func parseMetadata(doc: Document) -> (category: String?, date: Date?) {
        var category: String? = nil
        var date: Date? = nil

        // Парсим категорию
        if let categoryElement = try? doc.select(".topic-header__rubric").first() {
            category = try? categoryElement.text()
        }

        // Парсим дату (уже есть в NewsItem, но можем дополнить)
        if let timeElement = try? doc.select(".topic-header__time, .premium-header__time").first() {
            let dateString = try? timeElement.text()
            // TODO: Можно добавить парсинг даты из строки, если нужно
        }

        return (category: category, date: date)
    }

    /// Парсит блок автора
    private func parseAuthor(element: Element) -> ArticleContentType? {
        do {
            let name = try element.select(".topic-authors__name").first()?.text() ?? ""
            let photo = try element.select(".topic-authors__photo").attr("src")
            let jobTitle = try element.select(".topic-authors__job").first()?.text()

            if !name.isEmpty {
                return .author(
                    name: name,
                    photo: photo.isEmpty ? nil : photo,
                    jobTitle: jobTitle
                )
            }
        } catch {
            // Ignore parsing errors
        }

        return nil
    }

    /// Парсит отдельный элемент контента
    private func parseContentElement(element: Element) -> ArticleContentType? {
        do {
            let tagName = element.tagName()

            // Параграф текста - пробуем разные варианты классов
            if tagName == "p" {
                // Старые классы: topic-body__content-text
                // Новые классы: могут быть просто <p> без специальных классов
                let text = try element.text()
                let isLead = element.hasClass("_lead") || element.hasClass("topic-body__content-text--lead")

                if !text.isEmpty {
                    return .paragraph(text: text, isLead: isLead)
                }
            }

            // Подзаголовок - пробуем h2, h3
            else if (tagName == "h2" || tagName == "h3") {
                let text = try element.text()

                if !text.isEmpty {
                    return .subheading(text: text)
                }
            }

            // Изображение
            else if tagName == "figure" && element.hasClass("picture") {
                return parseImage(element: element)
            }

            // Цитата
            else if tagName == "div" && element.hasClass("box-quote") {
                return parseQuote(element: element)
            }

            // Инфобокс
            else if tagName == "div" && element.hasClass("box-note") {
                return parseInfoBox(element: element)
            }

            // Связанные материалы
            else if tagName == "div" && element.hasClass("box-inline-topic") {
                return parseRelatedMaterial(element: element)
            }

        } catch {
            // Ignore parsing errors
        }

        return nil
    }

    /// Парсит изображение с подписью
    private func parseImage(element: Element) -> ArticleContentType? {
        do {
            let imgElement = try element.select("img.picture__image").first()
            let url = try imgElement?.attr("src") ?? ""

            // Парсим подпись и кредиты
            var caption: String? = nil
            var credit: String? = nil

            if let figcaption = try? element.select("figcaption.description").first() {
                // Кредиты/авторство
                if let creditsElement = try? figcaption.select(".description__credits").first() {
                    credit = try creditsElement.text()
                }

                // Описание (если есть другой текст помимо кредитов)
                let fullText = try? figcaption.text()
                if let full = fullText, let cred = credit {
                    caption = full.replacingOccurrences(of: cred, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    if caption?.isEmpty == true {
                        caption = nil
                    }
                }
            }

            if !url.isEmpty {
                return .image(url: url, caption: caption, credit: credit)
            }

        } catch {
            // Ignore parsing errors
        }

        return nil
    }

    /// Парсит блок цитаты
    private func parseQuote(element: Element) -> ArticleContentType? {
        do {
            let quoteText = try element.select(".box-quote__content-text").first()?.text() ?? ""
            let authorName = try element.select(".box-quote__author-name").first()?.text() ?? ""
            let authorDescription = try element.select(".box-quote__author-description").first()?.text()

            if !quoteText.isEmpty {
                return .quote(
                    text: quoteText,
                    authorName: authorName,
                    authorDescription: authorDescription
                )
            }

        } catch {
            // Ignore parsing errors
        }

        return nil
    }

    /// Парсит информационный блок
    private func parseInfoBox(element: Element) -> ArticleContentType? {
        do {
            let text = try element.select(".box-note__text").first()?.text() ?? ""

            if !text.isEmpty {
                return .infoBox(text: text)
            }

        } catch {
            // Ignore parsing errors
        }

        return nil
    }

    /// Парсит связанные материалы
    private func parseRelatedMaterial(element: Element) -> ArticleContentType? {
        do {
            // Берем первую карточку связанного материала
            if let card = try? element.select(".card-inline-topic").first() {
                let title = try card.select(".card-inline-topic__title").first()?.text() ?? ""
                let description = try? card.select(".card-inline-topic__rightcol").first()?.text()
                let imageUrl = try? card.select(".card-inline-topic__image").attr("src")
                let articleUrl = try card.attr("href")
                let date = try? card.select(".card-inline-topic__date").first()?.text()

                if !title.isEmpty && !articleUrl.isEmpty {
                    // Формируем полный URL если это относительный путь
                    let fullUrl = articleUrl.hasPrefix("http") ? articleUrl : "https://lenta.ru\(articleUrl)"

                    return .relatedMaterial(
                        title: title,
                        description: description,
                        imageUrl: imageUrl,
                        articleUrl: fullUrl,
                        date: date
                    )
                }
            }

        } catch {
            // Ignore parsing errors
        }

        return nil
    }
}
