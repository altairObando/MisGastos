import Foundation
import Supabase

class AccountHelper {
    static let shared = AccountHelper()
    private init() {}

    func getAll() async -> [Account] {
        do {
            return try await SupabaseClient.shared.client.from("Account").select().execute().value
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func getById(_ id: UUID) async -> Account? {
        do {
            let items: [Account] = try await SupabaseClient.shared.client.from("Account").select().eq("id", value: id).execute().value
            return items.first
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func create(_ account: Account) async -> Bool {
        do {
            _ = try await SupabaseClient.shared.client.from("Account").insert(account).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func update(_ account: Account) async -> Bool {
        do {
            _ = try await SupabaseClient.shared.client.from("Account").update(account).eq("id", value: account.id).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func delete(_ id: UUID) async -> Bool {
        do {
            _ = try await SupabaseClient.shared.client.from("Account").delete().eq("id", value: id).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
