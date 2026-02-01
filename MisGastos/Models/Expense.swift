//
//  Expense.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/26/26.
//


import SwiftData
import Foundation

@Model
class Expense {
    var id: UUID
    var amount: Double
    var title: String
    var descript: String?
    var date: Date
    var isRecurring: Bool
    var recurringType: RecurringType?
    var tags: [String]
    
    // Relaciones
    @Relationship(deleteRule: .nullify) var category: Category
    @Relationship(deleteRule: .nullify) var account: Account?
    
    init(amount: Double, title: String, description: String? = nil, 
         date: Date = Date(), category: Category, account: Account? = nil, isIncome: Bool = false) {
        self.id = UUID()
        self.amount = amount
        self.title = title
        self.descript = description
        self.date = date
        self.isRecurring = false
        self.tags = []
        self.category = category
        self.account = account
    }
}

enum RecurringType: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
}
