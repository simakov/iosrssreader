//
//  PlatformAsyncImage.swift
//  NewsRSSReaderShared
//
//  Platform-aware image loading wrapper
//  iOS: Uses SDWebImageSwiftUI for caching
//  watchOS: Uses native AsyncImage
//

import SwiftUI

#if os(iOS)
import SDWebImageSwiftUI

public struct PlatformAsyncImage: View {
    let url: URL?
    let contentMode: ContentMode

    public init(url: URL?, contentMode: ContentMode = .fit) {
        self.url = url
        self.contentMode = contentMode
    }

    public var body: some View {
        WebImage(url: url)
            .resizable()
            .indicator(.activity)
            .aspectRatio(contentMode: contentMode == .fit ? .fit : .fill)
    }
}

#elseif os(watchOS)

public struct PlatformAsyncImage: View {
    let url: URL?
    let contentMode: ContentMode

    public init(url: URL?, contentMode: ContentMode = .fit) {
        self.url = url
        self.contentMode = contentMode
    }

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode == .fit ? .fit : .fill)
            case .failure:
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
}

#endif
