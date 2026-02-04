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
}
