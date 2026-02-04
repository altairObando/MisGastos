//
//  History.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/28/26.
//

import SwiftUI
import SwiftData

struct History: View {
    @State private var searchText: String = String();
    @State private var expenses: [TimeExpense] = [];
    @State private var selectedPeriod: TimePeriod = .thisWeek
    @State private var categories: [Category] = []
    @State private var category: Category?
    @AppStorage("currencyCode") private var currencyCode: String = "NIO"
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
                                Text(expense.amount, format: .currency(code: currencyCode))
                                    .foregroundStyle( expense.category.isIncome ? .green : .red  )
                            }
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
        Task {
            let range = selectedPeriod.dateRange;
            let startDate = range.start.startOfDay;
            let endDate   = range.end.endOfDay;
            do{
                let tempExpenses = await ExpenseHelper.shared.filterExpenses(
                    start: startDate,
                    end: endDate,
                    text: searchText,
                    catId: category?.id?.uuidString
                )
                expenses = tempExpenses
            } catch{
                print("Error getting expenses")
            }
        }
    }
    func loadCategories(){
        Task{
            let result = await CategoryHelper.shared.getAll();
            categories = result.filter{ cat in
                cat.isActive
            }
        }
    }
}
#Preview {
    History()
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
}
