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
    var categoryId: UUID?
    var category: Category?
    
    init(name: String, amount: Double, period: BudgetPeriod, category: Category) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.period = period
        self.startDate = Date()
        self.endDate = period.calculateEndDate(from: Date())
        self.isActive = true
        self.category = category
        self.categoryId = category.id
    }
    static func == (lhs: Budget, rhs: Budget) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.amount == rhs.amount &&
        lhs.period == rhs.period &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.isActive == rhs.isActive &&
        lhs.categoryId == rhs.categoryId
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

struct BudgetWithTotals: Codable, Identifiable {
    var id: UUID
    var name: String
    var amount: Double
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var categoryId: UUID?
    var category: Category?
    var totalSpent: Double
    var available: Double {
        max(0, self.amount - self.totalSpent)
    }
    var consumed: Double {
        guard self.amount != 0 else { return 0 }
        return self.totalSpent / self.amount
    }
    init(
        id: UUID,
        name: String,
        amount: Double,
        startDate: Date,
        endDate: Date,
        isActive: Bool,
        categoryId: UUID? = nil,
        category: Category? = nil,
        totalSpent: Double
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.categoryId = categoryId
        self.category = category
        self.totalSpent = totalSpent
    }
    init(from dto: BudgetWithTotalsResponse ){
        self.id = dto.id;
        self.name = dto.name;
        self.amount = dto.amount
        self.startDate = dto.startDate.toLocalDate()
        self.endDate = dto.endDate.toLocalDate()
        self.isActive = dto.isActive
        self.categoryId = dto.categoryId
        self.category = dto.category
        self.totalSpent = dto.totalspent
    }
}
struct NewBudget: Codable {
    var categoryId: UUID?
    var name: String
    var amount: Double
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    init(from dto: Budget){
        self.categoryId = dto.categoryId
        self.name = dto.name;
        self.amount = dto.amount
        self.startDate = dto.startDate
        self.endDate = dto.endDate
        self.isActive = true;
    }
}
struct BudgetWithTotalsResponse: Codable, Identifiable {
    var id: UUID
    var name: String
    var amount: Double
    var startDate: String
    var endDate: String
    var isActive: Bool
    var categoryId: UUID?
    var category: Category?
    var totalspent: Double
}
