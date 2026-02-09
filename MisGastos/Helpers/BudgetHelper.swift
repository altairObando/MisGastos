//
//  BudgetHelper.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 2/4/26.
//

import Foundation
import UIKit
import Supabase

class BudgetHelper {
    static let shared = BudgetHelper()
    private let client = SupabaseClient.shared.client;
    init(){}
    func getAll( _ activeOnly: Bool = true) async -> [Budget]{
        do{
            let response: [Budget] = try await client
                        .from("Budget")
                        .select("id, name, amount, startDate, endDate, isActive, categoryId")
                        .eq("isActive", value: activeOnly)
                        .execute()
                        .value
            return response;
        }catch{
            print(error.localizedDescription)
            return []
        }
    }
    
    func getAllWithTotalsByCategory() async -> [BudgetWithTotals] {
        do{
            
            let response: [BudgetWithTotalsResponse] = try await client.from("budget_with_totals")
                .select()
                .eq("isActive", value: true)
                .execute()
                .value
            let categories = await CategoryHelper.shared.getAll()
            return response.map{ bud in
                var bud = BudgetWithTotals(from: bud);
                bud.category = categories.first{ cat in cat.id == bud.categoryId }
                return bud
                
            };
        }catch let error as DecodingError{
            print(error)
        } catch let error as PostgrestError{
            print(error)
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    func getById(_ id: UUID) async -> Budget? {
        do {
            let items: [Budget] = try await SupabaseClient.shared.client.from("Budget").select("*,categoryId").eq("id", value: id).execute().value
            return items.first
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func create(_ budget: Budget) async -> Bool {
        do {
            _ = try await SupabaseClient.shared.client.from("Budget").insert(NewBudget(from: budget)).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func update(_ budget: Budget) async -> Bool {
        do {
            _ = try await SupabaseClient.shared.client.from("Budget").update(budget).eq("id", value: budget.id).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func delete(_ id: UUID) async -> Bool {
        do {
            _ = try await SupabaseClient.shared.client.from("Budget").delete().eq("id", value: id).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func setBudgetActive(_ budgetId: UUID, active: Bool) async -> Bool {
        do {
            _ = try await SupabaseClient.shared.client
                .from("Budget")
                .update(["isActive": active])
                .eq("id", value: budgetId.uuidString)
                .execute()
            return true
        } catch {
            print("❌ Error al actualizar estado del budget:", error.localizedDescription)
            return false
        }
    }
}
