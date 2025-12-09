//
//  ArticleAuthorView.swift
//  NewsRSSReaderShared
//
//  Platform-aware view for iOS and watchOS
//

import SwiftUI

/// View for displaying article author information
public struct ArticleAuthorView: View {
    let name: String
    let photo: String?
    let jobTitle: String?

    public init(name: String, photo: String?, jobTitle: String?) {
        self.name = name
        self.photo = photo
        self.jobTitle = jobTitle
    }

    public var body: some View {
        HStack(spacing: platformPadding(base: 12)) {
            // Author photo - iOS only
            #if os(iOS)
            if let photoUrl = photo, let url = URL(string: photoUrl) {
                PlatformAsyncImage(url: url, contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .background(
                        Circle()
                            .fill(Color("Gray").opacity(0.2))
                    )
            } else {
                // Placeholder if no photo
                Circle()
                    .fill(Color("Gray").opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(Color("Gray"))
                    )
            }
            #endif

            // Author name and job title
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: platformSize(ios: 16, watch: 14), weight: .semibold))
                    .foregroundColor(Color("Black"))

                if let title = jobTitle, !title.isEmpty {
                    Text(title)
                        .font(.system(size: platformSize(ios: 12, watch: 10)))
                        .foregroundColor(Color("Gray").opacity(0.6))
                }
            }

            Spacer()
        }
        .padding(.horizontal, platformPadding(base: 16))
        .padding(.vertical, platformPadding(base: 12))
        .background(Color("LigthGrey").opacity(0.2))
    }
}
