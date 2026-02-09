import Foundation

struct Expense: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var amount: Double
    var title: String
    var descript: String?
    var date: Date
    var isRecurring: Bool
    var recurringType: RecurringType?
    var tags: [String]
    var categoryId: UUID
    // Para mostrar los datos de la categoria
    var category: Category?
    init( id: UUID, amount: Double, title: String, date: Date, isRecurring: Bool, tags: [String], categoryId: UUID, category: Category? = nil){
        self.id = id
        self.amount = amount
        self.title = title
        self.descript = String()
        self.date = date
        self.isRecurring = isRecurring
        self.recurringType = .monthly
        self.tags = tags
        self.categoryId = categoryId
        self.category = category
    }
        
    init(from dto: ExpenseResponse){
        self.id = dto.id
        self.amount = dto.amount
        self.title = dto.title
        self.descript = dto.descript
        self.date = dto.date.toLocalDate()
        self.isRecurring = dto.isRecurring
        self.recurringType = dto.recurringType
        self.tags = dto.tags
        self.categoryId = dto.categoryId
        self.category = dto.category
    }
}

struct ExpenseResponse: Codable {
    var id: UUID
    var amount: Double
    var title: String
    var descript: String?
    var date: String
    var isRecurring: Bool
    var recurringType: RecurringType?
    var tags: [String]
    var categoryId: UUID
    var category: Category?
}
struct NewExpenseDto: Codable {
    var id: UUID
    var amount: Double
    var title: String
    var descript: String?
    var date: Date
    var isRecurring: Bool
    var tags: [String]
    var categoryId: UUID
    init(from dto: Expense){
        self.id = dto.id
        self.amount = dto.amount
        self.title = dto.title
        self.descript = dto.descript
        self.date = dto.date
        self.isRecurring = dto.isRecurring
        self.tags = dto.tags
        self.categoryId = dto.categoryId
    }
}
enum RecurringType: String, CaseIterable, Codable {
    case daily, weekly, monthly, yearly
}
