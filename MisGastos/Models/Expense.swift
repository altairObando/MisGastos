import Foundation

struct Expense: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var amount: Double
    var title: String
    var descript: String?
    var date: Date
    var isRecurring: Bool
    var recurringType: RecurringType?
    var tags: [String]
    // Foreign Key
    var categoryId: UUID
    var userId: UUID
    // Para mostrar los datos de la categoria
    var category: Category?
}

enum RecurringType: String, CaseIterable, Codable {
    case daily, weekly, monthly, yearly
}
