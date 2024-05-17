//
//  SelectedTabModifier.swift
//  NewsRSSReader
//
//  Created by Andrey Simakov on 17.05.2024.
//

import SwiftUI

struct SelectedTabModifier: ViewModifier{
    func body(content: Content) -> some View {
        return content
            .padding(8)
            .background(Color("LigthGrey"))
            .cornerRadius(17)
    }
}
