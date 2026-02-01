//
//  SummaryCard.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/27/26.
//

import SwiftUI
import SwiftData
struct SummaryCard: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var currentMonthExpenses: [Expense]
    var incomes: Double {
            currentMonthExpenses
            .filter { $0.category.isIncome }
                .reduce(0) { $0 + $1.amount }
        }
    var expenses: Double {
            currentMonthExpenses
                .filter { !$0.category.isIncome }
                .reduce(0) { $0 + $1.amount }
        }
    var balance: Double {
        incomes - expenses
    }
    init() {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now        
        _currentMonthExpenses = Query(
            filter: #Predicate { expense in
                expense.date >= startOfMonth && expense.date <= endOfMonth
            },
            sort: \.date,
            order: .reverse
        )
    }
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.2))
                .shadow( color: .bgColorLigth.opacity(0.2), radius: 5, x: 0, y: 3 )
            // Contenido
            VStack(alignment: .leading, spacing: 8) {
                HStack{
                    Text("Balance General")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Spacer()
                    ChipView(text:"+12 %")
                }
                
                Text(balance, format: .currency(code: "NIO"))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.gray)
                    .lineLimit(3)
                Spacer()
                HStack{
                    ZStack(alignment: .leading){
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6).opacity(0.2))
                            .shadow( color: .bgColorLigth.opacity(0.2),radius: 5,x: 0,y: 3)
                        VStack(alignment: .leading){
                            Text("INGRESO MENSUAL")
                                .font(.footnote.bold())
                                .foregroundColor(.white)
                            Text(incomes, format: .currency(code: "NIO"))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.green)
                        }.padding()
                    }
                    Spacer()
                    ZStack(alignment: .leading){
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6).opacity(0.2))
                            .shadow( color: .bgColorLigth.opacity(0.2),radius: 5,x: 0,y: 3)
                        VStack(alignment: .leading){
                            Text("GASTO MENSUAL")
                                .font(.footnote.bold())
                                .foregroundColor(.white)
                            Text(expenses, format: .currency(code: "NIO"))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.red)
                        }.padding()
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .padding(.horizontal)
    }
   
}

#Preview {
    SummaryCard()
        .globalBackground()
        .modelContainer(for: [Expense.self, Category.self], inMemory: false){ result in
            switch result {
                case .success( let container): setupDefaultData(container: container)
                case .failure(let error): print(error.localizedDescription)
            }
        }
}


