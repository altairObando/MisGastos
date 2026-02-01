//
//  MisGastosApp.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/26/26.
//

import SwiftUI
import SwiftData

@main
struct MisGastosApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self, Category.self, Account.self, Budget.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false );
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            setupDefaultData(container: container)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
func setupDefaultData(container: ModelContainer) {
    let context = container.mainContext

    // Solo crear categorías si no existen
    let categoryCount = (try? context.fetchCount(FetchDescriptor<Category>())) ?? 0
    if categoryCount == 0 {
        // Crear categorías con IDs explícitos para poder relacionarlas
        let defaultCategories = [
            Category(name: "Salario", icon: "fork.knife", isIncome: true),
            Category(name: "Alimentación", icon: "fork.knife"),
            Category(name: "Transporte", icon: "car.fill"),
            Category(name: "Entretenimiento", icon: "gamecontroller.fill"),
            Category(name: "Salud", icon: "heart.fill"),
            Category(name: "Compras", icon: "bag.fill"),
            Category(name: "Servicios", icon: "wrench.fill")
        ]

        // Insertar categorías en el contexto
        defaultCategories.forEach { context.insert($0) }
        try? context.save()
    }
    
}

enum AppError: Error {
    case missingName
    case missingCategory
    case missingAmount
    case missingDate
    
    var description: String {
        switch(self){
            case .missingName: "El nombre es obligatorio"
            case .missingAmount: "El monto debe ser mayor a cero"
            case .missingDate: "Debe indicar una fecha"
            case .missingCategory: "La categoria es obligatoria"
        }
    }
}
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
