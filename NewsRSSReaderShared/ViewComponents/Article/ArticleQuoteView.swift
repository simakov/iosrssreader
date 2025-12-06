//
//  ArticleQuoteView.swift
//  NewsRSSReaderShared
//
//  Platform-aware view for iOS and watchOS
//

import SwiftUI

/// View for displaying quote with author
public struct ArticleQuoteView: View {
    let text: String
    let authorName: String
    let authorDescription: String?

    public init(text: String, authorName: String, authorDescription: String?) {
        self.text = text
        self.authorName = authorName
        self.authorDescription = authorDescription
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: platformPadding(base: 12)) {
            // Quote text
            HStack(alignment: .top, spacing: 8) {
                // Quotation marks
                Text("«")
                    .font(.system(size: platformSize(ios: 36, watch: 24), weight: .bold))
                    .foregroundColor(Color("Red"))
                    .offset(y: platformSize(ios: -8, watch: -4))

                Text(text)
                    .font(.system(size: platformSize(ios: 17, watch: 14), weight: .medium))
                    .foregroundColor(Color("Black"))
                    .lineSpacing(platformSize(ios: 4, watch: 2))
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Quote author
            VStack(alignment: .leading, spacing: 2) {
                if !authorName.isEmpty {
                    Text(authorName)
                        .font(.system(size: platformSize(ios: 15, watch: 13), weight: .semibold))
                        .foregroundColor(Color("Black"))
                }

                if let description = authorDescription, !description.isEmpty {
                    Text(description)
                        .font(.system(size: platformSize(ios: 14, watch: 12)))
                        .foregroundColor(Color("Gray"))
                }
            }
        }
        .padding(platformPadding(base: 16))
        .background(
            Color("LigthGrey").opacity(0.3)
        )
        .cornerRadius(platformSize(ios: 8, watch: 6))
        .padding(.horizontal, platformPadding(base: 16))
        .padding(.vertical, platformPadding(base: 12))
    }
}
