//
//  ContentView.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/26/26.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ExpenseDataManager
    @StateObject private var tabSelection = TabSelection()
    
    @State private var currentTab: CustomTabs = .Home;
    @State private var demoSearch: String = String();
    
    init() {
        let container = try! ModelContainer(for: Expense.self, Category.self)
        _viewModel = StateObject(wrappedValue: ExpenseDataManager(context: container.mainContext))
        let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear

            // 👇 Cambiar color del ítem seleccionado y no seleccionado
            UITabBar.appearance().tintColor = UIColor.systemBlue       // Activo
            UITabBar.appearance().unselectedItemTintColor = UIColor.gray // Inactivo

            // Aplicar la apariencia
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    var body: some View {
        TabView(selection: $tabSelection.currentTab){
            Tab("Inicio", systemImage: "house", value: .Home){
                HomeView()
            }
            Tab("Presupuesto", systemImage: "wallet.bifold", value: .Budgets){
                Budgets()
            }
            Tab("Nuevo", systemImage: "plus", value: .NewExpense){
                AddOrUpdateExpense()
            }
            Tab("Ajustes", systemImage:"gear", value: .Config){
                NavigationStack{
                    VStack{
                        List{
                            Text("Datos Personales")
                            Text("Categorias")
                            Text("Cuentas")
                            Text("Sync")
                        }
                    }
                }.globalBackground()
            }
            Tab("Historial", systemImage:"magnifyingglass",value: .History, role: .search){
                History()
            }
        }.globalBackground()
        .environmentObject(tabSelection)
        .environmentObject(viewModel)
    }
}

#Preview {
    ContentView().modelContainer(for: Expense.self, inMemory: false)
}

enum CustomTabs: String, CaseIterable, Hashable {
     case Home
     case Budgets
     case NewExpense
     case Config
     case History
}

class TabSelection: ObservableObject {
    @Published var currentTab: CustomTabs = .Home
}


struct SearchView: View {
    @State var searchText: String = ""
    
    
    var body: some View {
        NavigationStack {
            VStack {
                ContentUnavailableView("Search Tab", systemImage: "magnifyingglass")
            }
            .navigationTitle("Search")
        }
        .searchable(
            text: $searchText,
            placement: .sidebar,
            prompt: "type here to search"
        ).globalBackground()
            .foregroundStyle(.white)
    }
}
