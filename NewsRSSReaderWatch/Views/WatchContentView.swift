//
//  WatchContentView.swift
//  NewsRSSReaderWatch
//
//  Root view for watchOS app
//

import SwiftUI
import NewsRSSReaderShared

struct WatchContentView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            WatchHomeView(viewModel: viewModel)
        }
    }
}

#Preview {
    WatchContentView()
}
