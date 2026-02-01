//
//  ChipView.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/27/26.
//

import SwiftUI

struct ChipView: View {
    let text: String

    var body: some View {
        Button{} label: {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.bgColorLigth)
                .foregroundColor(.white)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
