//
//  Account.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/26/26.
//

import SwiftData
import Foundation

@Model
class Account {
    var id: UUID
    var name: String
    var type: AccountType
    var balance: Double
    var currency: String
    var isActive: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.account)
    var expenses: [Expense] = []
    
    init(name: String, type: AccountType, balance: Double = 0.0, currency: String = "USD") {
        self.id = UUID()
        self.name = name
        self.type = type
        self.balance = balance
        self.currency = currency
        self.isActive = true
    }
}

enum AccountType: String, CaseIterable, Codable {
    case cash = "cash"
    case debitCard = "debit_card"
    case creditCard = "credit_card"
    case savings = "savings"
    case checking = "checking"
}

