import Foundation
import Supabase

class DeviceHelper {
    static let shared = DeviceHelper()
    private init() {}

    func getAll() async -> [Device] {
        do {
            return try await SupabaseClient.shared.client.from("Device").select().execute().value
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func create(_ device: Device) async -> Bool {
        do {
            _ = try await SupabaseClient.shared.client.from("Device").insert(device).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
