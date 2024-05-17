//
//  FadeDownViewModifier.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 17.05.2024.
//

import SwiftUI

struct FadeDownViewModifier: ViewModifier{
    func body(content: Content) -> some View {
        return content
            .overlay(
                LinearGradient(gradient: Gradient(colors: [.clear, Color("Background")]),
                               startPoint: .center,
                               endPoint: .bottom)
            )
    }
}
