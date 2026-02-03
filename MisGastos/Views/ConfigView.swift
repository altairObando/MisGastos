//
//  ConfigView.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 2/2/26.
//

import SwiftUI
import LocalAuthentication

struct ConfigView: View {
    @State private var showEditName = false
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("currencyCode") private var currencyCode: String = "NIO"
    @AppStorage("useFaceID") private var useFaceID: Bool = false
    @StateObject private var authVM = AuthViewModel()
    @State private var showFaceIDSnackbar = false
    @State private var faceIDErrorMessage = ""
    @State private var moveToCategories = false;

    var deviceName = UIDevice.current.name
    let currencies: [String: String] = [
        "NIO": "Córdoba (NIO)",
        "USD": "Dólar (USD)",
        "EUR": "Euro (EUR)"
    ]
    var currencyName: String {
        guard let cur = currencies[currencyCode] else {
            return "Córdoba (NIO)"
        }
        return cur
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .center, spacing: 10) {
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.white, .gray)
                            .background(
                                Circle().fill(Color(.systemGray5).opacity(0.5))
                            ).overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            )
                        Text(userName.isEmpty ? deviceName : userName)
                            .font(.footnote)
                    }
                    CustomSection("Cuenta") {
                        Button {
                            withAnimation {
                                showEditName.toggle()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "person")
                                Text(userName.isEmpty ? deviceName : userName)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        }
                        SectionSeparator()
                        HStack {
                            Image(systemName: "lock")
                            Text("Face ID al iniciar")
                            Spacer()
                            Toggle(isOn: Binding(
                                get: { useFaceID },
                                set: { newValue in
                                    if newValue {
                                        // Intento de activar: solicita autenticación
                                        authVM.authenticate()
                                    } else {
                                        // Desactivar directamente
                                        useFaceID = false
                                    }
                                }
                            )) {
                                EmptyView()
                            }
                            .labelsHidden()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .onChange(of: authVM.isUnlocked) {
                            if authVM.isUnlocked && !useFaceID {
                                useFaceID = true
                                authVM.isUnlocked = false
                            }
                        }
                        .onChange(of: authVM.errorMessage) {
                            if let err = authVM.errorMessage, !err.isEmpty {
                                faceIDErrorMessage = err
                                showFaceIDSnackbar = true
                                useFaceID = false
                                authVM.errorMessage = nil
                            }
                        }
                    }
                    CustomSection("General") {
                        Menu {
                            ForEach(Array(currencies.keys), id: \.self) { key in
                                Button {
                                    currencyCode = key
                                } label: {
                                    Label(currencies[key] ?? key, systemImage: currencyCode == key ? "checkmark" : "")
                                }
                            }
                        }
                    label: {
                        HStack {
                            Image(systemName: "dollarsign.circle")
                            Text(currencyName)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }.padding(.horizontal).padding(.vertical, 10)
                    }
                        SectionSeparator()
                        Button {
                            moveToCategories.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "shippingbox")
                                Text("Categorias")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }.padding(.horizontal).padding(.vertical, 10)
                        }
                    }
                    CustomSection("Datos") {
                        Button {} label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Importar")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }.padding(.horizontal).padding(.vertical, 10)
                        }
                        SectionSeparator()
                        Button {} label: {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Exportar")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }.padding(.horizontal).padding(.vertical, 10)
                        }
                        SectionSeparator()
                        Button {} label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Eliminar")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }.foregroundStyle(.red)
                                .padding(.horizontal).padding(.vertical, 10)
                        }
                    }
                    Text("Mis Gastos App")
                        .font(.title3.bold())
                        .foregroundStyle(.gray)
                    Text("Hecho con amor para gui17")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                .padding()
                .globalBackground()
                .foregroundStyle(.white)
                .sheet(isPresented: $showEditName) {
                    VStack(alignment: .center) {
                        Text("Actualiza tu nombre")
                        TextField("", text: $userName)
                            .textFieldStyle(.roundedBorder)
                        Button("Completado") {
                            withAnimation {
                                showEditName.toggle()
                            }
                        }.buttonStyle(.borderedProminent)
                            .foregroundStyle(.white)
                    }
                    .foregroundStyle(.primary)
                    .padding()
                    .presentationDetents(
                        [.height(300)]
                    )
                }
                .navigationDestination(isPresented: $moveToCategories){
                    CategoriesView()
                }
                // Snackbar: error de Face ID
                if showFaceIDSnackbar {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(.yellow)
                            Text(faceIDErrorMessage)
                                .foregroundStyle(.primary)
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        .onAppear {
                            // Oculta el snackbar después de 2.5 segundos
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation {
                                    showFaceIDSnackbar = false
                                    faceIDErrorMessage = ""
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: showFaceIDSnackbar)
                }
            }
        }
    }
}

#Preview {
    ConfigView()
}
