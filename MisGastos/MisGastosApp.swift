//
//  MisGastosApp.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/26/26.
//

import SwiftUI
import SwiftData

@main
struct MisGastosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

enum AppError: Error {
    case missingName
    case missingCategory
    case missingAmount
    case missingDate
    
    var description: String {
        switch(self){
            case .missingName: "El nombre es obligatorio"
            case .missingAmount: "El monto debe ser mayor a cero"
            case .missingDate: "Debe indicar una fecha"
            case .missingCategory: "La categoria es obligatoria"
        }
    }
}
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
