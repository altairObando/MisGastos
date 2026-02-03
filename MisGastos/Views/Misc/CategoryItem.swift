//
//  CategoryItem.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 2/3/26.
//

import SwiftUI

struct CategoryItem: View {
    var cat: Category
    var onEdit: (_ category: Category) -> Void
    var onDelete: (_ category: Category) -> Void
    var body: some View {
        HStack(alignment: .center, spacing: 10){
            Image(systemName: cat.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding(12)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading){
                Text(cat.name)
                    .font(.headline)
                HStack(spacing: 5){
                    Text("Has Gastado")
                    Text(cat.totalSpent, format: .currency(code: "NIO"))
                }.font(.subheadline)
            }
            Spacer()
            Image(systemName: cat.isIncome ? "arrowshape.up" : "arrowshape.down")
                .foregroundStyle(cat.isIncome ? Color.green : Color.red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.2))
        )
        .swipeActions(edge: .leading){
            Button{
                onEdit(cat)
            }label: {
                Image(systemName:"pencil")
            }.tint(.yellow)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false){
            Button{
                onDelete(cat)
            } label:{
                Image(systemName:"trash")
            }.tint(.red)
        }
    }
}
