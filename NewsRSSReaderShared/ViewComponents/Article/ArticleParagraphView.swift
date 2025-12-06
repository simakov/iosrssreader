//
//  ArticleParagraphView.swift
//  NewsRSSReaderShared
//
//  Platform-aware view for iOS and watchOS
//

import SwiftUI

/// View for displaying text paragraph
public struct ArticleParagraphView: View {
    let text: String
    let isLead: Bool

    public init(text: String, isLead: Bool = false) {
        self.text = text
        self.isLead = isLead
    }

    public var body: some View {
        Text(text)
            .font(isLead ?
                .system(size: platformSize(ios: 17, watch: 15), weight: .medium) :
                .system(size: platformSize(ios: 16, watch: 14)))
            .foregroundColor(Color("Black"))
            .lineSpacing(platformSize(ios: 4, watch: 2))
            .padding(.horizontal, platformPadding(base: 16))
            .padding(.vertical, platformPadding(base: 8))
    }
}
