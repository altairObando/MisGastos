//
//  NoteField.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/27/26.
//

import SwiftUI

struct NoteField: View {
    @Binding var text: String
    @FocusState.Binding var focused: Bool
    var title: String = "Nota"
    var placeholder: String = "Referencias"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            HStack {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    .focused($focused)
                
                Spacer()
                
                Image(systemName: "note.text")
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6).opacity(0.2))
                    //.fill(Color(red: 0.11, green: 0.15, blue: 0.13)) // tono oscuro/verde
            )
        }
        .padding(.horizontal)
    }
}
private extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow { placeholder() }
            self
        }
    }
}
