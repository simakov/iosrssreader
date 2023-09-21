//
//  News.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 20.09.2023.
//

import Foundation


class News {
    let guid: String
    let author: String
    let title: String
    let link: String
    let description: String
    let pubDate: String
    let enclosure: String
    let category: String
    init(guid: String, author: String, title: String, link: String, description: String, pubDate: String, enclosure: String, category: String) {
        self.guid = guid
        self.author = author
        self.title = title
        self.link = link
        self.description = description
        self.pubDate = pubDate
        self.enclosure = enclosure
        self.category = category
    }
}
