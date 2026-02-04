//
//  CategoriesExtensions.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/28/26.
//
import SwiftData
import Foundation

extension ModelContext {
//    func categorySummariesForMonth(_ date: Date = Date()) -> [CategorySummary] {
//        let calendar = Calendar.current
//        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
//        let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end ?? date
//        let expenseDescriptor = FetchDescriptor<Expense>(
//            predicate: #Predicate { expense in
//                expense.date >= startOfMonth && expense.date <= endOfMonth && !expense.category.isIncome && expense.category.isActive
//            },
//            sortBy: [SortDescriptor(\.date)]
//        )
//        
//        guard let expenses = try? fetch(expenseDescriptor) else {
//            return []
//        }
//        let grouped = Dictionary(grouping: expenses) { $0.category }
//        return grouped.compactMap { (category, categoryExpenses) in
//            let total = categoryExpenses.reduce(0) { $0 + $1.amount }
//            return CategorySummary(category: category, total: total)
//        }
//        .sorted { $0.total > $1.total }
//    }
//    func getCategories(_ isIncome: Bool = false) -> [Category]{
//        let descriptor = FetchDescriptor<Category>(
//            predicate: #Predicate { cat in
//                cat.isIncome == isIncome
//            },
//            sortBy: [SortDescriptor(\.name)]
//        )
//        guard let categories = try? fetch(descriptor) else {
//            return []
//        }
//        return categories
//    }
}
