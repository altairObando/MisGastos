//
//  AddOrUpdateBudget.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/29/26.
//

import SwiftUI

struct AddOrUpdateBudget: View {
    @Environment(\.dismiss) private var dissmiss
    var budgetId: UUID?
    @State private var budget: Budget?
    @State private var categories: [Category] = [];
    @State private var id: UUID = UUID()
    @State private var name = String();
    @State private var amount : Double = 0.0;
    @State private var period: BudgetPeriod = .monthly;
    @State private var start: Date = Date()
    @State private var active: Bool = false;
    @State private var category: Category? = nil;
    @State private var showDatePicker = false;
    
    @State private var showAlert = false;
    @State private var alertMessage = String();
    
    var endDate: Date {
        return period.calculateEndDate(from: start)
    }
    
    var body: some View {
        VStack(alignment: .leading){
            CustomSection("Informacion General"){
                HStack{
                    Text("Nombre")
                    Spacer()
                    TextField(String(),text: $name)
                        .submitLabel(.done)
                }.padding()
                SectionSeparator()
                HStack{
                    Text("Monto: ")
                    Spacer()
                    TextField(String(), value: $amount, format: .number)
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
                }.padding()
                SectionSeparator()
                HStack{
                    Text("Categoria")
                    Spacer()
                    Menu{
                        ForEach(categories){ cat in
                            Button(cat.name, systemImage: cat.icon){
                                withAnimation{
                                    self.category = cat
                                }
                            }
                        }
                    } label: {
                        HStack{
                            Text(category?.name ?? "Ninguna")
                            Image(systemName: category?.icon ?? "shippingbox")
                        }.padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6).opacity(0.2))
                    )
                }.padding()
            }
            CustomSection("Duracion"){
                HStack{
                    Text("Fecha de Inicio")
                    Spacer()
                    Button{
                        withAnimation{
                            showDatePicker.toggle()
                        }
                    }label: {
                        HStack{
                            Text(formatDate(start))
                            Image(systemName: "calendar")
                        }.padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6).opacity(0.2))
                    )
                }
                SectionSeparator()
                HStack{
                    Text("Periodo")
                    Spacer()
                    Menu{
                        ForEach(BudgetPeriod.allCases){ periodo in
                            Button(periodo.name){
                                period = periodo
                            }
                        }
                    } label: {
                        HStack{
                            Text(period.name)
                            Image(systemName: "calendar")
                        }.padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6).opacity(0.2))
                    )
                }
                SectionSeparator()
                HStack{
                    Text("Fecha Fin")
                    Spacer()
                    Text(formatDate(endDate))
                }
            }
            .sheet(isPresented: $showDatePicker){
                VStack(alignment: .center, spacing: 20 ){
                    Text("Seleccione una fecha").foregroundStyle(.black)
                    DatePicker("Fecha", selection: $start, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                    Button("Aceptar"){
                        showDatePicker.toggle()
                    }.buttonStyle(.borderedProminent)
                }.presentationDetents(
                    [.height(500)]
                ).padding()
            }
            Button("Guardar", systemImage: "tray.and.arrow.down.fill") {
                addUpdateBudget()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.bgColorLigth)
            .foregroundColor(.white)
            .cornerRadius(8)
            .onAppear{
                fetchCategories()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Listo") {
                    hideKeyboard()
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Ha ocurrido un error", isPresented: $showAlert){
            Button("Aceptar", role: .confirm){}
        } message: {
            Text(alertMessage)
        }.toolbarColorScheme(.dark, for: .navigationBar)
        .globalBackground()
        .foregroundStyle(.white)
        .onAppear{
            Task{
                guard let itemId = budgetId else {
                    return;
                }
                let response = await BudgetHelper.shared.getById(itemId)
                if let bud = response {
                    id = bud.id;
                    name = bud.name;
                    amount = bud.amount
                    period = bud.period
                    start = bud.startDate
                    active = bud.isActive
                    category = bud.category
                }
            }
            
        }
    }
    func addUpdateBudget(){
        Task{
            do{
                alertMessage = String()
                if name.isEmpty {
                    throw AppError.missingAmount
                }
                if amount <= 0 {
                    throw AppError.missingAmount
                }
                if category == nil {
                    throw AppError.missingCategory
                }

                var completed = false
                if let _ = budgetId {
                    let updated = Budget(name: name, amount: amount, period: period, category: category!)
                    updated.id = id
                    updated.startDate = start
                    updated.endDate = endDate
                    updated.isActive = active
                    completed = await BudgetHelper.shared.update(updated)
                } else {
                    let newBudget = Budget(name: name, amount: amount, period: period, category: category!)
                    newBudget.id = id
                    newBudget.startDate = start
                    newBudget.endDate = endDate
                    newBudget.isActive = true
                    
                    completed = await BudgetHelper.shared.create(newBudget)
                }
                if !completed {
                    throw AppError.errorOnCreateBudget
                }
                dissmiss()
            } catch let error as AppError {
                alertMessage = error.description;
            } catch {
                alertMessage = "Error no identificado."
            }
            if !alertMessage.isEmpty {
                showAlert.toggle()
            }
        }
    }
    func fetchCategories(){
        Task{
            let cats = await CategoryHelper.shared.getAll()
            categories = cats.filter{ cat in cat.isActive }
        }
    }
}

#Preview {
    AddOrUpdateBudget()
}

