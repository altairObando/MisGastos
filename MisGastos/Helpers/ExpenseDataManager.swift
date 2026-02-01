import SwiftUI
import SwiftData
import Combine

class ExpenseDataManager: ObservableObject {
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // Gastos por mes
    func expensesForCurrentMonth() -> [Expense] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
        
        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate { expense in
                expense.date >= startOfMonth && expense.date <= endOfMonth
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // Gastos por categoría
    func totalByCategory() -> [CategorySummary] {
        let descriptor = FetchDescriptor<Category>()
        let categories = (try? context.fetch(descriptor)) ?? []
        
        return categories.map { category in
            CategorySummary(
                category: category,
                total: category.totalSpent
            )
        }.filter { $0.total > 0 }
    }
    
    // Agregar un nuevo gasto
    func addExpense(_ expense: Expense) {
        context.insert(expense)
        try? context.save()
    }
    
    // Eliminar gasto
    func deleteExpense(_ expense: Expense) {
        context.delete(expense)
        try? context.save()
    }
    
    // Obtener total de gastos del mes
    func monthlyTotal() -> Double {
        return expensesForCurrentMonth()
            .filter{ !$0.category.isIncome }
            .reduce(0) { $0 + $1.amount }
    }
    func expenseByRange(from start: Date, to end: Date) -> [Expense]{
        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate { expense in
                expense.date >= start && expense.date <= end
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getExpenseById( for id: UUID) -> Expense?{
        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate{ expense in
                expense.id == id
            }
        )
        return ((try? context.fetch(descriptor)) ?? []).first
    }
}

enum TimePeriod: String, CaseIterable {
    case thisWeek = "Esta Semana"
    case thisMonth = "Este Mes"
    case thisYear = "Este Año"
    case all = "Todo"
    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        switch self {
            case .thisWeek:
                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
                let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
                return (startOfWeek, endOfWeek)
            case .thisMonth:
                let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
                let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
                return (startOfMonth, endOfMonth)
            case .thisYear:
                let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
                let endOfYear = calendar.dateInterval(of: .year, for: now)?.end ?? now
                return (startOfYear, endOfYear)
            case .all:
                return (Date.distantPast, Date.distantFuture)
        }
    }
}
