import Foundation

struct Device: Codable, Identifiable, Equatable {
    let id: UUID
    var deviceId: UUID
}
