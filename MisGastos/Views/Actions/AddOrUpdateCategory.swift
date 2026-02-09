//
//  AddOrUpdateCategor.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 2/3/26.
//

import SwiftUI
struct AddOrUpdateCategory: View {
    @Environment(\.dismiss) private var dismiss
    var cat: Category?
    @State private var name: String = String()
    @State private var iconName: String = "shippingbox"
    @State private var isActive: Bool = false;
    @State private var isIncome: Bool = false;
    @State private var showIconSelector = false;
    var body: some View {
        VStack(alignment: .center){
            VStack(alignment: .center){
                Image(systemName: iconName )
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .shadow(radius: 5)
                Button("Icono", systemImage:"pencil"){
                    showIconSelector = true
                }
                .buttonStyle(.borderedProminent)
                .foregroundStyle(.white)
            }
            CustomSection("Información"){
                VStack(alignment: .leading){
                    Text("Nombre:").foregroundStyle(.white)
                    TextField(String(), text: $name)
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundStyle(.black)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                SectionSeparator()
                HStack{
                    Text("Activa")
                    Spacer()
                    Toggle(isOn: $isActive){}.labelsHidden()
                }.padding(.horizontal)
                .padding(.vertical, 10)
                HStack{
                    Text("Credito")
                    Spacer()
                    Toggle(isOn: $isIncome){}.labelsHidden()
                }.padding(.horizontal)
                .padding(.vertical, 10)
            }.foregroundStyle(.white)
            Button("Guardar", systemImage:"shippingbox.and.arrow.backward"){
                Task{
                    if let existing = cat {
                        let updatedCategory = Category(
                            id: existing.id,
                            name: name,
                            icon: iconName,
                            isActive: isActive,
                            isIncome: isIncome
                        )
                        _ = await CategoryHelper.shared.update(updatedCategory)
                    } else {
                        let newCategory = Category(
                            id: UUID(),
                            name: name,
                            icon: iconName,
                            isActive: isActive,
                            isIncome: isIncome
                        )
                        _ = await CategoryHelper.shared.create(newCategory)
                    }
                    dismiss()
                }
            }.padding()
            .foregroundStyle(.white)
            .buttonStyle(.glassProminent)
            if let category = cat {
                Button("Eliminar \( category.name )", systemImage:"trash", role: .destructive){
                    Task{
                        if let existing = cat {
                            _ = await CategoryHelper.shared.delete(existing.id)
                        }
                        dismiss()
                    }
                }.buttonStyle(.glass)
                    .foregroundStyle(.red)
            }
            
        }.globalBackground()
        .sheet(isPresented: $showIconSelector){
            NavigationStack{
                IconSelector(){ newName in
                    iconName = newName;
                    showIconSelector = false;
                }.presentationDetents([.height(600)])
            }
        }
        .onAppear {
            if let category = cat {
                name = category.name;
                iconName = category.icon;
                isActive = category.isActive;
                isIncome = category.isIncome
            }
        }
    }
}

#Preview {
    AddOrUpdateCategory()
}

struct IconSelector: View {
    var callback: ((_ iconName: String) -> Void)?
    @State private var searchText: String = String()
    let symbolKeywords: [String: String] = [
        "shippingbox": "caja, envíos, paquetes, objetos",
        "cart": "carro, carrito, pedidos, supermercado, compras",
        "creditcard": "tarjeta, crédito, débito, pagos",
        "banknote": "billete, efectivo, dinero, pago",
        "wallet.pass": "billetera, cartera, finanzas",
        "dollarsign.circle": "dinero, dólar, ahorro, ingreso",
        "piggy.bank": "ahorro, guardar, alcancía",
        "chart.pie": "gráfica, resumen, análisis, reporte",
        "chart.bar": "barras, estadística, gráfico, progreso",
        "star": "favorito, destacado, mejor",
        "heart": "salud, bienestar, preferido, amor",
        "person": "usuario, persona, perfil, personal",
        "house": "hogar, casa, vivienda, alquiler",
        "fork.knife": "comida, restaurante, alimentos, cocina",
        "bag": "bolsa, compras, mercado",
        "car": "auto, transporte, gasolina, vehículo",
        "bus": "bus, transporte, colectivo",
        "airplane": "viaje, avión, vuelo, transporte",
        "gift": "regalo, obsequio, cumpleaños",
        "bolt": "energía, luz, electricidad, servicio",
        "flame": "gas, calor, cocina, energía",
        "doc.plaintext": "documento, factura, recibo, nota",
        "building.columns": "banco, institución, impuestos",
        "tray": "bandeja, recibir, ingresos, registrar",
        "envelope": "correo, factura, recibo, mensaje",
        "globe": "internet, global, mundial, red",
        "clock": "tiempo, hora, recordatorio, calendario",
        "calendar": "fecha, evento, agenda, planificar",
        "phone": "llamada, contacto, comunicación, teléfono",
        "leaf": "ecología, natural, verde, ahorro",
        "cart.badge.plus": "agregar, compra, añadir, supermercado",
        "cart.badge.minus": "eliminar, quitar, descuento, compra",
        "fuelpump": "gasolina, combustible, auto, gasto",
        "train.side.front.car": "tren, transporte, viaje",
        "bed.double": "hotel, descanso, hospedaje, viaje",
        "wifi": "internet, conexión, red, servicio",
        "tshirt": "ropa, vestimenta, tienda",
        "pawprint": "mascota, animal, veterinario",
        "cross.case": "salud, medicina, seguro",
        "camera": "foto, cámara, recuerdo",
        "cup.and.saucer": "café, bebida, desayuno, comida",
        "cart.fill": "carrito lleno, compras, supermercado",
        "house.fill": "hogar, casa, residencia"
    ]
    var filteredIcons: [String: String]{
        if searchText.isEmpty{
            return symbolKeywords
        }
        return symbolKeywords.filter { icon in
            icon.value.uppercased().contains(searchText.uppercased())
        }
    }
    var body: some View {
        List {
            ForEach(filteredIcons.sorted(by: { $0.key < $1.key }), id: \.key) { (icon, keywords) in
                HStack {
                    Image(systemName: icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .padding(.trailing, 8)
                    VStack(alignment: .leading) {
                        Text(icon)
                            .font(.headline)
                        Text(keywords)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .onTapGesture {
                    callback?(icon)
                }
                .padding(.vertical, 4)
            }
        }.navigationTitle("Selecciona un icono")
        .searchable(text: $searchText, prompt: "Buscar icono")
    }
}
