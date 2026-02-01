//
//  Category.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/26/26.
//
import SwiftData
import Foundation


@Model
class Category {
    var id: UUID
    var name: String
    var icon: String
    var budgetLimit: Double?
    var isActive: Bool
    var isIncome: Bool
    
    // Relación inversa
    @Relationship(deleteRule: .cascade, inverse: \Expense.category) 
    var expenses: [Expense] = []
    
    init(name: String, icon: String = "folder", isIncome: Bool = false) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.isIncome =  isIncome
        self.isActive = true
    }
    
    // Computed property para el total gastado
    var totalSpent: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
}
