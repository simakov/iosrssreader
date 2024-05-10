//
//  RSSFeedItem.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 10.05.2024.
//

import Foundation
import FeedKit

extension RSSFeedItem: Identifiable {
            
    func publishedDate() -> String {
        guard let date = pubDate else { return "" }
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        let fullDateFormatter = DateFormatter()
        
        // Set the date format for the current day (time only)
        dateFormatter.dateFormat = "HH:mm"
        
        // Set the date format for all other days (date and time)
        let fullDateFormat = "d.MM HH:mm"
        fullDateFormatter.dateFormat = fullDateFormat
        
        let calendar = Calendar.current
        
        // Comparing dates to determine if the date is the current day
        let components1 = calendar.dateComponents([.day, .month, .year], from: date)
        let components2 = calendar.dateComponents([.day, .month, .year], from: currentDate)
        
        if components1.day == components2.day && components1.month == components2.month && components1.year == components2.year {
            // If the date is the current day, we return only the time
            return dateFormatter.string(from: date)
        } else {
            // If the date is not the current day, return the date and time
            return fullDateFormatter.string(from: date)
        }
    }
    static func sample() -> RSSFeedItem {
        let sample = RSSFeedItem()
        sample.title = "Песков предупредил о происходящих в мире тектонических изменениях"
        sample.description = "В мире происходят тектонические изменения. Организация Объединенных наций (ООН) должна к ним адаптироваться. Об этом предупредил пресс-секретарь президента России Дмитрий Песков."
        sample.pubDate = Date()
        sample.enclosure = RSSFeedItemEnclosure()
        sample.enclosure?.attributes?.url = "https://icdn.lenta.ru/images/2023/09/20/16/20230920163731575/pic_e8e6cfaf91098f77b5efec4625e837ff.jpg"
        let category = RSSFeedItemCategory()
        category.value = "Мир"
        sample.categories = [category]
        return sample
    }
}
