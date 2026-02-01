//
//  GlobalBackground.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/28/26.
//
import SwiftUI

struct GlobalBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color.bgColorDark],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            content
        }
    }
}

extension View {
    func globalBackground() -> some View {
        modifier(GlobalBackground())
    }
}
