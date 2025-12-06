//
//  ArticleSubheadingView.swift
//  NewsRSSReaderShared
//
//  Platform-aware view for iOS and watchOS
//

import SwiftUI

/// View for displaying subheading
public struct ArticleSubheadingView: View {
    let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.system(size: platformSize(ios: 20, watch: 16), weight: .bold))
            .foregroundColor(Color("Black"))
            .lineSpacing(platformSize(ios: 4, watch: 2))
            .padding(.horizontal, platformPadding(base: 16))
            .padding(.top, platformPadding(base: 20))
            .padding(.bottom, platformPadding(base: 8))
    }
}
