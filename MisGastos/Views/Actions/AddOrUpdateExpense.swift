//
//  AddOrUpdateExpense.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/26/26.
//

import SwiftUI
import SwiftData
import Combine

struct AddOrUpdateExpense: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var tabSelection: TabSelection
    @EnvironmentObject var dataManager: ExpenseDataManager
    @State private var errMessage: String = "Ha ocurrido un error al guardar el registro"
    @State private var errShown: Bool = false;
    @State private var categories: [Category] = [];
    @StateObject private var vm = ExpenseViewModel(
        category: nil,
        score: 0,
        selectedDate: Date(),
        notas: String()
    )
    @FocusState private var amountFocus : Bool;
    @FocusState private var noteFocus: Bool
    @State private var showIncomes = false;
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Monto del \( showIncomes ? "Ingreso" : "Gasto" )")
                .font(.title)
                .foregroundStyle(.white)
            TextField(String(), value: $vm.amount, format: .number)
                .font(.system(size: 40, weight: .bold))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .focused($amountFocus)
            VStack(alignment: .leading){
                HStack{
                    Text("Categorias")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    HStack {
                        Text("Ingresos")
                            .foregroundStyle(.white)
                            .font(.subheadline)
                        Toggle("", isOn: $showIncomes)
                            .labelsHidden()
                    }
                }
                ScrollView{
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 50, maximum: .infinity)),
                        GridItem(.flexible(minimum: 50, maximum: .infinity)),
                        GridItem(.flexible(minimum: 50, maximum: .infinity))
                    ], alignment: .leading, spacing: 8 ){
                        ForEach(
                            categories,
                            id: \.id){ cat in
                            VStack(alignment: .center, spacing: 8 ){
                                Image(systemName: cat.icon)
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(.white)
                                Text(cat.name)
                                    .font(.footnote)
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 100, height: 100)
                            .border(Color.bgColorLigth, width: 2)
                            .background(
                                (cat.id == vm.category?.id) ? Color.bgColorLigth : Color(
                                    .systemGray6
                                )
                                .opacity(0.2)
                            )
                            .cornerRadius(10)
                            .onTapGesture {
                                vm.category = cat;
                            }
                        }
                    }
                }
                .frame(maxHeight: 250)
            }.padding()
            DatePickerField(selectedDate: $vm.selectedDate)
            NoteField(text: $vm.notas, focused: $noteFocus)
            VStack{
                Button("Guardar \(showIncomes ? "Ingreso": "Gasto")", systemImage: "tray.and.arrow.down.fill") {
                    saveNewExpense()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.bgColorLigth)
                .foregroundColor(.white)
                .cornerRadius(8)
            }.padding()
        }
        .onAppear {
            loadCategories()
        }
        .onChange(of: showIncomes){
            loadCategories()
        }
        .toolbar{
            ToolbarItem(placement: .keyboard ){
                Button("Completado"){
                    amountFocus = false;
                    noteFocus = false;
                }
            }
        }
        .alert("Error",isPresented: $errShown){
            Button(role: .cancel){}
        } message: {
            Text(errMessage)
        }
        .padding()
        .globalBackground()
    }
    func saveNewExpense(){
        do {
            if vm.amount <= 0 {
                throw AppError.missingAmount
            }
            if vm.category == nil {
                throw AppError.missingCategory
            }
            
            let expense = Expense(
                amount: vm.amount,
                title: vm.notas,
                date: vm.selectedDate,
                category: vm.category!,
            )
            dataManager.addExpense(expense)
            vm.clearData()
            withAnimation {
                tabSelection.currentTab = .Home;
            }
        } catch let error as AppError {
            errMessage = error.description
            errShown.toggle()
        } catch {
            errMessage = "Ha ocurrido un error al guardar el registro"
            errShown.toggle()
        }
    }
    private func loadCategories() {
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { cat in
                cat.isIncome == showIncomes
            },
            sortBy: [SortDescriptor(\.name)]
        )
        withAnimation{
            do {
                categories = try modelContext.fetch(descriptor)
            } catch {
                print("Error fetching categories: \(error)")
                categories = []
            }
        }
    }
}
#Preview {
    AddOrUpdateExpense()
        .modelContainer(for: [Expense.self, Category.self], inMemory: true){ result in
            switch result {
                case .success( let container): setupDefaultData(container: container)
                case .failure(let error): print(error.localizedDescription)
            }
        }
}
