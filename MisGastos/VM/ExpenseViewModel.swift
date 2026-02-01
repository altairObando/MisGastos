//
//  ExpenseViewModel.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/27/26.
//
import SwiftUI
import Combine

class ExpenseViewModel: ObservableObject {
    @Published var category: Category? = nil;
    @Published var amount: Double;
    @Published var selectedDate: Date;
    @Published var notas: String;
    
    init(
        category: Category? = nil,
        score: Double,
        selectedDate: Date,
        notas: String
    ) {
        self.category = category
        self.amount = score
        self.selectedDate = selectedDate
        self.notas = notas
    }
    func clearData(){
        self.category = nil
        self.amount = 0
        self.selectedDate = Date()
        self.notas = String()
    }
}
