import Foundation

struct Category: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let userId: UUID
    var name: String
    var icon: String
    var isActive: Bool
    var isIncome: Bool
}
