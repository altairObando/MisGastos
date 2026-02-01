//
//  CategorySummary.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/26/26.
//
import Foundation
import SwiftUI

class CategorySummary: Identifiable {
    var id: UUID
    let category: Category
    let total: Double
    var color: Color?  // Color opcional para la visualización

    init(category: Category, total: Double, color: Color? = nil) {
        self.id = UUID()
        self.category = category
        self.total = total
        self.color = color
    }
}
