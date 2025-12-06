//
//  NewsRSSReaderWatch_ExtensionBundle.swift
//  NewsRSSReaderWatch Extension
//
//  Created by Andrey Simakov on 06.12.2025.
//

import WidgetKit
import SwiftUI

@main
struct NewsRSSReaderWatch_ExtensionBundle: WidgetBundle {
    var body: some Widget {
        NewsRSSReaderWatch_Extension()
        NewsRSSReaderWatch_ExtensionControl()
    }
}
