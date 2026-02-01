//
//  DatePickerField.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/27/26.
//

import SwiftUI

struct DatePickerField: View {
    @Binding var selectedDate: Date
    var title: String = "Fecha"
    
    private var formattedDate: String {
        return formatDate(selectedDate)
    }
    
    @State private var showPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white)
            
            Button {
                showPicker.toggle()
            } label: {
                HStack {
                    Text(formattedDate)
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundStyle(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6).opacity(0.2))
                )
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showPicker) {
                VStack {
                    DatePicker(
                        "Selecciona una fecha",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    
                    Button("Aceptar") {
                        showPicker = false
                    }
                    .padding(.bottom)
                }
            }
        }
        .padding(.horizontal)
    }
}

func formatDate(_ selectedDate: Date ) -> String {
    let calendar = Calendar.current
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "es_ES")

    // Hoy y Ayer (solo tienen sentido en el año actual)
    if calendar.isDateInToday(selectedDate) {
        return "Hoy "
    } else if calendar.isDateInYesterday(selectedDate) {
        formatter.dateFormat = "d 'de' MMMM"
        let base = formatter.string(from: selectedDate).capitalized(with: .current)
        return "Ayer " + base
    }

    // Decidir formato según si es el mismo año
    let isSameYear = calendar.component(.year, from: selectedDate) == calendar.component(.year, from: Date())
    if isSameYear {
        formatter.dateFormat = "d 'de' MMMM"
    } else {
        formatter.dateFormat = "d 'de' MMMM 'de' y"
    }

    return formatter.string(from: selectedDate).capitalized(with: .current)
}
