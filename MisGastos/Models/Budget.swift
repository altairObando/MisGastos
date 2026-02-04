//
//  Budget.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/26/26.
//

import Foundation
class Budget: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var amount: Double
    var period: BudgetPeriod
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var category: Category
    var userId: UUID?
    
    init(name: String, amount: Double, period: BudgetPeriod, category: Category) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.period = period
        self.startDate = Date()
        self.endDate = period.calculateEndDate(from: Date())
        self.isActive = true
        self.category = category
    }
    static func == (lhs: Budget, rhs: Budget) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.amount == rhs.amount &&
        lhs.period == rhs.period &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.isActive == rhs.isActive &&
        lhs.category == rhs.category
    }
}

enum BudgetPeriod: String, CaseIterable, Codable, Identifiable {
    case weekly = "weekly"
    case monthly = "monthly"
    case quarterly = "quarterly"
    case semester = "semester"
    case yearly = "yearly"
    
    var id: Self { self }
    
    func calculateEndDate(from startDate: Date) -> Date {
        let calendar = Calendar.current
        switch self {
            case .weekly:
                return calendar.date(byAdding: .weekOfYear, value: 1, to: startDate) ?? startDate
            case .monthly:
                return calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate
            case .quarterly:
                return calendar.date(byAdding: .month, value: 3, to: startDate) ?? startDate
                case .semester:
                    return calendar.date(byAdding: .month, value: 6, to: startDate) ?? startDate
            case .yearly:
                return calendar.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        }
    }
    
    var name: String{
        switch (self){
            case .monthly: "Mensual"
            case .weekly : "Semanal"
            case .quarterly: "Trimestral"
            case .semester: "Semestral"
            case .yearly: "Anual"
        }
    }
}

