//
//  ExpensesChart.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/27/26.
//

import SwiftUI
import SwiftData
import Charts

struct ExpensesChart: View {
    @Environment(\.modelContext) private var modelContext
    @State private var summary : [CategorySummary] = [];
    
    var body: some View {
        ZStack(alignment: .leading){
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.2))
                .shadow( color: .bgColorLigth.opacity(0.2), radius: 5, x: 0, y: 3 )
            VStack(alignment: .center, spacing: 10 ){
                HStack{
                    Text("Resumen de gastos")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("Ver reporte")
                        .font(.footnote.bold())
                        .foregroundStyle(.green)
                }.padding()
                Chart(summary){ item in
                    SectorMark(
                        angle: .value("Categoria", item.total),
                        innerRadius: .ratio(0.6),
                        outerRadius: .ratio(1)
                    )
                    .foregroundStyle(item.color ?? .blue)
                }
                .frame(height: 200)
                let columns = [GridItem(.adaptive(minimum: 100), spacing: 10)]
                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    ForEach(summary) { item in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(item.color ?? .blue)
                                .frame(width: 12, height: 12)
                            Text(item.category.name)
                                .foregroundColor(.white)
                                .font(.footnote)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }.frame(maxWidth: .infinity)
        .frame(height: 400)
        .padding(.horizontal)
        .onAppear(perform: GetCategoriesSummary )
    }
    
    func GetCategoriesSummary(){
        summary = modelContext
            .categorySummariesForMonth()
            .map{ cat in
                cat.color = getRandomColor()
                return cat
            }
    }
    func getRandomColor() -> Color {
        return Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

#Preview {
    ExpensesChart()
        .globalBackground()
        .modelContainer(for: [Expense.self, Category.self], inMemory: false){ result in
            switch result {
                case .success( let container): setupDefaultData(container: container)
                case .failure(let error): print(error.localizedDescription)
            }
        }
}

