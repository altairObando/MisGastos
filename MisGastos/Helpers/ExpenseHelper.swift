import Foundation
import UIKit
import Supabase

class ExpenseHelper {
    static let shared = ExpenseHelper()
    private let client = SupabaseClient.shared.client;
    private let userId = UIDevice.current.identifierForVendor?.uuidString
    private let ExpenseSelect = "*, category:Category(id, name, icon, isActive, isIncome)"
    private init() {}

    func getAll() async -> [Expense] {
        do {
            return try await client.from("Expense").select(ExpenseSelect).eq("userId", value: userId).execute().value
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func getById(_ id: UUID) async -> Expense? {
        do {
            let items: [Expense] = try await client.from("Expense").select().eq("userId", value: userId).eq("id", value: id).execute().value
            return items.first
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func create(_ expense: Expense) async -> Bool {
        do {
            _ = try await client.from("Expense").insert(expense).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func update(_ expense: Expense) async -> Bool {
        do {
            _ = try await client.from("Expense").update(expense).eq("userId", value: userId).eq("id", value: expense.id).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func delete(_ id: UUID) async -> Bool {
        do {
            _ = try await client.from("Expense").delete().eq("userId", value: userId).eq("id", value: id).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func currentMonthExpenses() async -> [Expense]{
        let calendar = Calendar.current
        let now = Date()
        let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
        let start = formatter.string(from: startOfMonth)
        let end = formatter.string(from: endOfMonth)
        do{
            let result: [Expense] = try await client.from("Expense")
                .select(ExpenseSelect)
                .gte("date", value: start)
                .lte("date", value: end)
                .eq("userId", value: userId)
                .execute()
                .value;
            return result
        }catch{
            print(error.localizedDescription)
            return []
        }
    }
    func filterExpenses(start : Date, end: Date, text: String = String(), catId: String? = nil ) async -> [TimeExpense]{
        do{
            var builder = client.from("Expense").select(ExpenseSelect)
                .eq("userId", value: userId)
                .gte("date", value: start)
                .lte("date", value: end)
            if !text.isEmpty {
                builder = builder.ilike("title", pattern: text)
            }
            if let catId = catId, !catId.isEmpty{
                builder = builder.eq("categoryId", value: catId)
            }
            let tempExpenses: [Expense] = try await builder.order("date", ascending: false).execute().value;
            
            let groupedDict = Dictionary(grouping: tempExpenses) { expense -> Date in
                expense.date.startOfDay
            }
            let catExpenses = groupedDict.map { date, expenses in
                TimeExpense(date: date, expenses: expenses)
            }
            return catExpenses.sorted { $0.date > $1.date };
        } catch{
            print(error.localizedDescription)
            return []
        }
    }
}
struct TimeExpense: Identifiable, Decodable {
    let id = UUID()
    var date: Date
    var expenses: [Expense]
}
