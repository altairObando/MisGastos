//
//  Budgets.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/28/26.
//

import SwiftUI
import SwiftData

struct Budgets: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Budget> { $0.isActive }) private var allActiveBudgets: [Budget]
    @AppStorage("currencyCode") private var currencyCode: String = "NIO"
    @State private var showNewItem = false;
    @State private var showOptions = true;
    @State private var selected: Budget? = nil;
    @State private var budgetId: UUID = UUID();

    let thresholds: [(threshold: Double, color: Color, label: String)] = [
        (0.5, .green, "Dentro del presupuesto"),
        (0.75, .yellow, "Cerca del límite"),
        (0.9, .orange, "Superando presupuesto"),
        (1.0, .red, "Presupuesto excedido")
    ]
    var budgets: [Budget] {
        let today = Date()
        return allActiveBudgets.filter { b in
            b.startDate.startOfDay >= today.startOfDay && b.startDate.endOfDay <= today.endOfDay
        }
    }

    var totalBudget: Double {
        budgets.reduce(0.0) { (initial: Double, next: Budget) in
            initial + next.amount
        }
    }
    var totalExpense: Double {
        budgets.reduce(0.0) { (initial: Double, next: Budget) in
            initial + next.totalSpent
        }
    }
    var consumed: Double {
        let budget = totalBudget
        guard budget > 0 else { return 0 }
        return totalExpense / budget
    }
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                HStack{
                    ZStack(alignment: .leading){
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6).opacity(0.2))
                            .shadow( color: .bgColorLigth.opacity(0.2),radius: 5,x: 0,y: 3)
                        VStack(alignment: .leading, spacing: 10 ){
                            Text("Total Gastado Mensual")
                                .font(.title)
                                .foregroundColor(.white)
                            HStack{
                                Text(totalExpense,format: .currency(code: currencyCode))
                                    .font(.system(size: 25, weight: .bold))
                                    .foregroundStyle(Color.white)
                                Text("/")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(Color.gray)
                                Text(totalBudget, format: .currency(code: currencyCode))
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(Color.gray)
                            }
                            CustomProgressBar(
                                progress: consumed,
                                height: 20,
                                cornerRadius: 10,
                                showPercentage: true,
                                showThresholds: false,
                                thresholds: thresholds
                            )
                        }
                        .padding()
                    }.padding()
                }.frame(height: 200)
                VStack(alignment: .leading){
                    Text("Categorias")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    ScrollView{
                        ForEach(budgets){ bud in
                            BudgetItem(
                                bud: bud,
                                fColor: getCurrentColor(bud.consumedPercentage),
                                thresholds: thresholds,
                                callBack: onBudgetPress
                            )
                        }
                    }
                }.padding(.horizontal)
            }
            .navigationTitle("Presupuestos")
            .globalBackground()
            .toolbarColorScheme(.dark, for: .navigationBar)
            .overlay{
                if budgets.isEmpty{
                    ContentUnavailableView("Sin Registros", systemImage: "wallet.bifold.fill")
                        .globalBackground()
                        .foregroundStyle(.white)
                }
            }
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Button("New", systemImage: "plus"){
                        selected = nil;
                        showNewItem.toggle()
                    }
                }
            }
            .navigationDestination(isPresented: $showNewItem){
                AddOrUpdateBudget(budget: selected)
            }
            .onAppear{
                selected = nil
            }
        }.toolbarColorScheme(.dark, for: .navigationBar)
    }
    func getCurrentColor( _ progress: Double) -> Color {
        for (threshold, color, _) in thresholds.sorted(by: { $0.threshold < $1.threshold }) {
            if progress <= threshold {
                return color
            }
        }
        return thresholds.last?.color ?? .blue
    }
    func onBudgetPress(_ budget: Budget, action: BudgetAction){
        selected = nil;
        switch action {
            case .archive:
                budget.isActive = false;
            case .detail:
                selected = budget;
                showNewItem.toggle()
            case .delete:
                modelContext.delete(budget);
            case .cancel:
                print("Action Cancelled")
        }
    }
}

#Preview {
    Budgets()
}

