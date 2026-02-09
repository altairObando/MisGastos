import Foundation
import UIKit
import Supabase

class ExpenseHelper {
    static let shared = ExpenseHelper()
    private let client = SupabaseClient.shared.client;
    private let ExpenseSelect = "*, category:Category(id, name, icon, isActive, isIncome)"
    private init() {}

    func getAll() async -> [Expense] {
        do {
            return try await client.from("Expense").select(ExpenseSelect).execute().value
        } catch let error as Supabase.PostgrestError {
            print(error)
            return []
        }
        catch {
            print(error.localizedDescription)
            return []
        }
    }

    func getById(_ id: UUID) async -> Expense? {
        do {
            let items: [Expense] = try await client.from("Expense").select().eq("id", value: id).execute().value
            return items.first
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func create(_ expense: Expense) async -> Bool {
        do {
            let dto = NewExpenseDto(from: expense)
            _ = try await client.from("Expense").insert(dto).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func update(_ expense: Expense) async -> Bool {
        do {
            _ = try await client.from("Expense").update(expense).eq("id", value: expense.id).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func delete(_ id: UUID) async -> Bool {
        do {
            _ = try await client.from("Expense").delete().eq("id", value: id).execute()
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
            let result: [ExpenseResponse] = try await client.from("Expense")
                .select(ExpenseSelect)
                .gte("date", value: start)
                .lte("date", value: end)
                .execute()
                .value;
            return result.map{ exp in Expense(from: exp ) }
        }catch let error as DecodingError {
            print(error)
        }
        catch{
            print(error.localizedDescription)
        }
        return []
    }
    func filterExpenses(start : Date, end: Date, text: String = String(), catId: String? = nil ) async -> [TimeExpense]{
        do{
            var builder = client.from("Expense").select(ExpenseSelect)
                .gte("date", value: start)
                .lte("date", value: end)
            if !text.isEmpty {
                builder = builder.ilike("title", pattern: text)
            }
            if let catId = catId, !catId.isEmpty{
                builder = builder.eq("categoryId", value: catId)
            }
            let tempExpenses: [ExpenseResponse] = try await builder.order("date", ascending: false).execute().value;
            
            let groupedDict = Dictionary(grouping: tempExpenses.map{ exp in Expense(from: exp )}) { expense -> Date in
                expense.date.startOfDay
            }
            let catExpenses = groupedDict.map { date, expenses in
                TimeExpense(date: date, expenses: expenses)
            }
            return catExpenses.sorted { $0.date > $1.date };
        } catch let error as DecodingError {
            print(error)
        }
        catch{
            print(error.localizedDescription)
        }
        return []
    }
}
struct TimeExpense: Identifiable, Decodable {
    let id = UUID()
    var date: Date
    var expenses: [Expense]
    private enum CodingKeys: String, CodingKey {
        case date
        case expenses
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
