//
//  ArticleInfoBoxView.swift
//  NewsRSSReaderShared
//
//  Platform-aware view for iOS and watchOS
//

import SwiftUI

/// View for displaying highlighted info box
public struct ArticleInfoBoxView: View {
    let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Wave at top
            Rectangle()
                .fill(Color("Red"))
                .frame(height: 3)

            // Text
            Text(text)
                .font(.system(size: platformSize(ios: 16, watch: 14), weight: .medium))
                .foregroundColor(Color("Black"))
                .lineSpacing(platformSize(ios: 4, watch: 2))
                .padding(platformPadding(base: 16))

            // Wave at bottom
            Rectangle()
                .fill(Color("Red"))
                .frame(height: 3)
        }
        .background(Color("LigthGrey").opacity(0.2))
        .cornerRadius(4)
        .padding(.horizontal, platformPadding(base: 16))
        .padding(.vertical, platformPadding(base: 12))
    }
}
