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
    let userId = UIDevice.current.identifierForVendor.unsafelyUnwrapped;
    init(){}
    func getAll() async -> [Budget]{
        do{
            let response: [Budget] = try await client
                        .from("Budget")
                        .select("""
                            id,
                            name,
                            amount,
                            startDate,
                            endDate,
                            isActive,
                            category:Category(id, name, icon, isActive, isIncome)
                        """)
                        .eq("userId", value: userId.uuidString)
                        .execute()
                        .value
            return response;
        }catch{
            print(error.localizedDescription)
            return []
        }
    }
    func getById(_ id: UUID) async -> Budget? {
        do {
            let items: [Budget] = try await SupabaseClient.shared.client.from("Budget").select("*,category:Category(id, name, icon, isActive, isIncome)").eq("userId", value: userId).eq("id", value: id).execute().value
            return items.first
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func create(_ category: Budget) async -> Bool {
        do {
            _ = try await SupabaseClient.shared.client.from("Budget").insert(category).execute()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func update(_ category: Budget) async -> Bool {
        do {
            _ = try await SupabaseClient.shared.client.from("Budget").update(category).eq("id", value: category.id).execute()
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
}
