//
//  ArticleImageView.swift
//  NewsRSSReaderShared
//
//  Platform-aware view for iOS and watchOS
//  Uses SDWebImage on iOS, AsyncImage on watchOS
//

import SwiftUI

/// View for displaying image with caption and authorship
public struct ArticleImageView: View {
    let url: String
    let caption: String?
    let credit: String?

    public init(url: String, caption: String?, credit: String?) {
        self.url = url
        self.caption = caption
        self.credit = credit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image - platform-specific via PlatformAsyncImage
            PlatformAsyncImage(url: URL(string: url), contentMode: .fit)
                .frame(maxWidth: .infinity)
                #if os(watchOS)
                .frame(maxHeight: 150)
                #endif
                .background(Color("Gray").opacity(0.2))

            // Caption and/or authorship
            VStack(alignment: .leading, spacing: 4) {
                if let caption = caption, !caption.isEmpty {
                    Text(caption)
                        .font(.system(size: platformSize(ios: 14, watch: 12)))
                        .foregroundColor(Color("Gray"))
                }

                if let credit = credit, !credit.isEmpty {
                    Text(credit)
                        .font(.system(size: platformSize(ios: 12, watch: 10)))
                        .foregroundColor(Color("Gray"))
                        .italic()
                }
            }
            .padding(.horizontal, platformPadding(base: 16))
        }
        .padding(.vertical, platformPadding(base: 12))
    }
}
