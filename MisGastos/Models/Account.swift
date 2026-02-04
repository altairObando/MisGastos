import Foundation

struct Account: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var type: AccountType
    var balance: Double
    var currency: String
    var isActive: Bool
}

enum AccountType: String, CaseIterable, Codable {
    case cash = "cash"
    case debitCard = "debit_card"
    case creditCard = "credit_card"
    case savings = "savings"
    case checking = "checking"
}
