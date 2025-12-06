//
//  WatchNewsRowPlaceholder.swift
//  NewsRSSReaderWatch
//
//  Loading placeholder for news row
//

import SwiftUI

struct WatchNewsRowPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 12)
                .cornerRadius(4)

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 100, height: 10)
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
        .redacted(reason: .placeholder)
    }
}

#Preview {
    List {
        WatchNewsRowPlaceholder()
        WatchNewsRowPlaceholder()
        WatchNewsRowPlaceholder()
    }
}
