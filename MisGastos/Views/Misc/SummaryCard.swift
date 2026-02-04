//
//  SummaryCard.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/27/26.
//

import SwiftUI
import SwiftData
struct SummaryCard: View {
    @State private var currentMonthExpenses: [Expense] = [];
    @State private var incomes: Double = 0.0
    @State private var expenses: Double = 0.0;
    @AppStorage("currencyCode") private var currencyCode: String = "NIO"
    
    var balance: Double {
        incomes - expenses
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
                
                Text(balance, format: .currency(code: currencyCode))
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
                            Text(incomes, format: .currency(code: currencyCode))
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
                            Text(expenses, format: .currency(code: currencyCode))
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
   
    func fetchExpenses() async -> Void{
        let result = await ExpenseHelper.shared.currentMonthExpenses()
        var inc = 0.0, exp = 0.0;
        result.forEach{ expense in
            if let cat = expense.category, cat.isIncome {
                inc += expense.amount
            } else {
                exp += expense.amount
            }
        }
        self.currentMonthExpenses = result;
        self.incomes = inc;
        self.expenses = exp;
    }
}

#Preview {
    SummaryCard()
        .globalBackground()
}


