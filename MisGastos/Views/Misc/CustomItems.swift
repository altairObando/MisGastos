//
//  SectionSeparator.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 2/1/26.
//
import Foundation
import SwiftUI


struct SectionSeparator: View {
    var body: some View {
        Rectangle()
            .fill(.gray)
            .frame(height: 1)
            .padding(.horizontal, 1)
    }
}
struct CustomSection<Content: View>: View{
    var title: String
    let content: () -> Content
    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            Text(title)
                .font(.title2.bold())
                .padding(.horizontal)
            VStack{
                content()
            }.padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.2))
            )
        }
    }
}
