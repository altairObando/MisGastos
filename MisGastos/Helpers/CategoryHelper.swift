import Foundation
import UIKit
import Supabase

class CategoryHelper {
    static let shared = CategoryHelper()
    private let client = SupabaseClient.shared.client;
    private init() {}

    func getAll() async -> [Category] {
        do {
            return try await client.from("Category").select().execute().value
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func getById(_ id: UUID) async -> Category? {
        do {
            let items: [Category] = try await client.from("Category").select().eq("id", value: id).execute().value
            return items.first
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func create(_ category: Category) async -> Bool {
        do {
            _ = try await client.from("Category").insert(category).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func update(_ category: Category) async -> Bool {
        do {
            _ = try await client.from("Category").update(category).eq("id", value: category.id).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func delete(_ id: UUID) async -> Bool {
        do {
            _ = try await client.from("Category").delete().eq("id", value: id).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func totalExpenseByCategory(_ categoryId: UUID) async -> Double{
        do{
            let result: ExpenseByCategoryDTO = try await client.from("Expense")
                .select("SUM(amount) AS total")
                .eq("categoryId", value: categoryId.uuidString)
                .single()
                .execute()
                .value
            return result.total
        }catch{
            print(error.localizedDescription)
            return 0.0
        }
    }
    func categorySummaries() async -> [CategorySummary]{
        let expenses = await ExpenseHelper.shared.currentMonthExpenses();
        let grouped = Dictionary(grouping: expenses) { $0.category }
        return grouped.compactMap { (category, categoryExpenses) in
            guard let category = category else { return nil }
            let total = categoryExpenses.reduce(0) { $0 + $1.amount }
            return CategorySummary(category: category, total: total)
        }.sorted { $0.total > $1.total }
    }
    struct ExpenseByCategoryDTO: Codable {
        var total: Double
    }
}
