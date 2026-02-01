//
//  History.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/28/26.
//

import SwiftUI
import SwiftData

struct History: View {
    @Environment(\.modelContext) private var modelContext
    @State private var searchText: String = String();
    @State private var expenses: [TimeExpense] = [];
    @State private var selectedPeriod: TimePeriod = .thisWeek
    @State private var categories: [Category] = []
    @State private var category: Category?
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Text("Historial de Transacciones")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "calendar")
                }.padding()
                HStack{
                    Menu{
                        ForEach(TimePeriod.allCases, id: \.self){ option in
                            Button(option.rawValue){
                                selectedPeriod = option
                            }
                        }
                    }
                    label: {
                        HStack{
                            Text(selectedPeriod.rawValue)
                                .font(.headline)
                            Image(systemName: "calendar")
                        }.frame(width: 150)
                    }.padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6).opacity(0.2))
                    )
                    Menu {
                        Button("Todas"){
                            category = nil
                        }
                        ForEach(categories){ cat in
                            Button(cat.name, systemImage: cat.isIncome ? "arrowshape.up": "arrowshape.down"){
                                category = cat
                            }
                        }
                    } label: {
                        HStack{
                            Text(category?.name ?? "Todas")
                                .font(.headline)
                            Image(systemName: "shippingbox")
                        }.frame(width: 130)
                    }.padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6).opacity(0.2))
                    )
                }.padding(.vertical)
                List(expenses){ cat in
                    Section(formatDate(cat.date)){
                        ForEach(cat.expenses) { expense in
                            HStack {
                                Image(systemName: expense.category.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .padding(12)
                                    .background(Color.gray.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                VStack(alignment: .leading){
                                    Text(expense.category.name)
                                        .font(.subheadline)
                                    Text(expense.title)
                                        .font(.footnote)
                                }
                                Spacer()
                                Text(expense.amount, format: .currency(code: "NIO"))
                                    .foregroundStyle( expense.category.isIncome ? .green : .red  )
                            }
                            //.foregroundStyle(.black)
                            .listRowBackground(Color.gray.opacity(0.3))
                        }
                    }
                }.scrollContentBackground(.hidden)
                .overlay{
                    if expenses.isEmpty {
                        ContentUnavailableView("No hay datos registrados", systemImage: "tray.fill")
                    }
                }
            }
            .onAppear(perform: filterExpenses)
            .onAppear(perform: loadCategories)
            .onChange(of: selectedPeriod){
                filterExpenses()
            }
            .onChange(of: category){
                filterExpenses()
            }
            .onChange(of: searchText){
                filterExpenses()
            }
            .globalBackground()
        }
        .foregroundStyle(.white)
        .navigationTitle("Historial de Transacciones")
        .searchable(
            text: $searchText,
            prompt: Text("Buscar Transacciones")
        ).toolbarColorScheme(.dark, for: .navigationBar)
    }
    func filterExpenses(){
        let range = selectedPeriod.dateRange;
        let startDate = range.start;
        let endDate   = range.end;
        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate { expense in
                expense.date >= startDate.startOfDay &&
                expense.date <= endDate.endOfDay
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do{
            var tempExpenses = try modelContext.fetch(descriptor);
            if let cat = category {
                tempExpenses = tempExpenses.filter{ exp in
                    exp.category == cat
                }
            }
            if !searchText.isEmpty {
                tempExpenses = tempExpenses.filter { expense in
                    expense.title.uppercased().contains( searchText.uppercased()) ||
                    expense.category.name.uppercased().contains(searchText.uppercased())
                }
            }
            let groupedDict = Dictionary(grouping: tempExpenses) { expense -> Date in
                expense.date.startOfDay
            }
            let catExpenses = groupedDict.map { categoryName, expenses in
                TimeExpense(date: categoryName, expenses: expenses)
            }
            expenses = catExpenses.sorted { $0.date > $1.date };
            
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                categories = [
                    Category(name: "Comida", icon: "fork.knife"),
                    Category(name: "Electronica", icon: "bolt"),
                    Category(name: "Ropa", icon:"hanger"),
                    Category(name: "Salud", icon:"heart"),
                    Category(name: "Salario", icon:"wallet.bifold", isIncome: true),
                    Category(name: "Extras", icon: "wand.and.stars", isIncome: true),
                    Category(name: "Ventas", icon:"storefront")
                ]
                var tempExpenses: [Expense] = [];
                for category in categories {
                    tempExpenses.append(contentsOf: [
                        Expense(amount: 100, title: "Supermercado", date: Date(), category: category),
                        Expense(amount: 50, title: "Gasolina", date: Date().addingTimeInterval(-86400), category: category),
                        Expense(amount: 200, title: "Restaurante", date: Date().addingTimeInterval(-172800), category: category)
                    ])
                }
                if let cat = category {
                    tempExpenses = tempExpenses.filter{ exp in
                        exp.category.name == cat.name
                    }
                }
                if !searchText.isEmpty {
                    tempExpenses = tempExpenses.filter { expense in
                        expense.title.uppercased().contains( searchText.uppercased()) ||
                        expense.category.name.uppercased().contains(searchText.uppercased())
                    }
                }
                let groupedDict = Dictionary(grouping: tempExpenses) { expense -> Date in
                    expense.date.startOfDay
                }
                let catExpenses = groupedDict.map { categoryName, expenses in
                    TimeExpense(date: categoryName, expenses: expenses)
                }
                expenses = catExpenses.sorted { $0.date > $1.date }
            }
        }catch{
            print("Error getting expenses")
        }
    }
    func loadCategories(){
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            categories = [
                Category(name: "Comida"),
                Category(name: "Electronica"),
                Category(name: "Ropa"),
                Category(name: "Salud"),
                Category(name: "Salario", isIncome: true),
                Category(name: "Extras", isIncome: true),
                Category(name: "Ventas")
            ]
        } else {
            categories = try! modelContext.fetch(FetchDescriptor<Category>())
        }
    }
}

struct TimeExpense: Identifiable {
    let id = UUID()
    var date: Date
    var expenses: [Expense]
}

#Preview {
    History()
        .modelContainer(for: [Expense.self, Category.self], inMemory: true){ result in
            switch result {
                case .success( let container): setupDefaultData(container: container)
                case .failure(let error): print(error.localizedDescription)
            }
        }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
}
