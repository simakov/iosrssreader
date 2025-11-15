//
//  ArticleLoaderService.swift
//  NewsRSSReader
//
//  Created on 2025-11-14.
//

import Foundation
import UIKit

/// Сервис для загрузки HTML контента статей
class ArticleLoaderService {
    /// Singleton instance
    static let shared = ArticleLoaderService()

    /// Custom URLSession с настройками для имитации Safari
    private lazy var safariSession: URLSession = {
        let config = URLSessionConfiguration.default

        // Настройки кэша как в Safari
        config.requestCachePolicy = .useProtocolCachePolicy
        config.urlCache = URLCache.shared

        // HTTP настройки
        config.httpShouldSetCookies = true
        config.httpCookieAcceptPolicy = .always
        config.httpShouldUsePipelining = true
        config.httpMaximumConnectionsPerHost = 6

        // Настройки безопасности
        config.tlsMinimumSupportedProtocolVersion = .TLSv12

        // Timeout как в Safari
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60

        // Headers по умолчанию
        config.httpAdditionalHeaders = self.getSafariHeaders()

        return URLSession(configuration: config)
    }()

    private init() {}

    /// Ошибки загрузки
    enum LoaderError: LocalizedError {
        case invalidURL
        case networkError(Error)
        case invalidResponse
        case noData

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Неверный URL адрес"
            case .networkError(let error):
                return "Ошибка сети: \(error.localizedDescription)"
            case .invalidResponse:
                return "Неверный ответ сервера"
            case .noData:
                return "Данные не получены"
            }
        }
    }

    /// Возвращает актуальные Safari headers для iOS
    private func getSafariHeaders() -> [String: String] {
        let iosVersion = UIDevice.current.systemVersion
        let deviceModel = UIDevice.current.model

        return [
            // Актуальный User-Agent для iOS Safari
            "User-Agent": "Mozilla/5.0 (\(deviceModel); CPU iPhone OS \(iosVersion.replacingOccurrences(of: ".", with: "_")) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(iosVersion.split(separator: ".").first ?? "18").0 Mobile/15E148 Safari/604.1",

            // Accept headers как в Safari
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7",
            "Accept-Encoding": "gzip, deflate, br",

            // Дополнительные headers
            "DNT": "1",
            "Connection": "keep-alive",
            "Upgrade-Insecure-Requests": "1",
            "Sec-Fetch-Dest": "document",
            "Sec-Fetch-Mode": "navigate",
            "Sec-Fetch-Site": "none"
        ]
    }

    /// Загружает HTML контент по указанному URL
    /// - Parameters:
    ///   - url: URL адрес статьи
    ///   - completion: Completion handler с результатом (HTML string или ошибка)
    func loadArticle(url: String, completion: @escaping (Result<String, LoaderError>) -> Void) {
        // Проверка валидности URL
        guard let articleURL = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }

        // Создаем URLRequest с Safari headers
        var request = URLRequest(url: articleURL)
        request.httpMethod = "GET"
        request.cachePolicy = .useProtocolCachePolicy

        // Добавляем Referer если это внутренняя ссылка
        if articleURL.host?.contains("lenta.ru") == true {
            request.setValue("https://lenta.ru/", forHTTPHeaderField: "Referer")
        }

        // Выполняем запрос через custom session
        let task = safariSession.dataTask(with: request) { data, response, error in
            // Обработка ошибок сети
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }

            // Проверка HTTP ответа
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }

            // Проверка наличия данных
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            // Конвертация данных в строку
            // Пробуем разные кодировки
            var htmlString: String?

            // Сначала пробуем UTF-8
            if let string = String(data: data, encoding: .utf8) {
                htmlString = string
            }
            // Затем пробуем Windows-1251 (может использоваться на некоторых российских сайтах)
            else if let string = String(data: data, encoding: .windowsCP1251) {
                htmlString = string
            }
            // Fallback на ISO Latin 1
            else if let string = String(data: data, encoding: .isoLatin1) {
                htmlString = string
            }

            guard let html = htmlString else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            // Возвращаем успешный результат
            DispatchQueue.main.async {
                completion(.success(html))
            }
        }

        task.resume()
    }
}
