//
//  AppError.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 2/9/26.
//
import Foundation

enum AppError: Error {
    case missingName
    case missingCategory
    case missingAmount
    case missingDate
    case errorOnCreateBudget
    
    var description: String {
        switch(self){
            case .missingName: "El nombre es obligatorio"
            case .missingAmount: "El monto debe ser mayor a cero"
            case .missingDate: "Debe indicar una fecha"
            case .missingCategory: "La categoria es obligatoria"
            case .errorOnCreateBudget: "Error al crear/actualizar presupuesto."
        }
    }
}
