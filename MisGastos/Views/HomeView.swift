//
//  HomeView.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/27/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    var body: some View {
        NavigationStack{
            ScrollView{
                SummaryCard()
                ExpensesChart()
            }
            .padding()
            .globalBackground()
            .navigationTitle("Resumen")
            .toolbarColorScheme(.dark, for: .navigationBar)
            
        }
    }
}

#Preview {
    HomeView()
    .modelContainer(for: [Expense.self, Category.self], inMemory: true){ result in
        switch result {
            case .success( let container): setupDefaultData(container: container)
            case .failure(let error): print(error.localizedDescription)
        }
    }
}
