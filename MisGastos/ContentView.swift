//
//  ContentView.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/26/26.
//

import SwiftUI
import SwiftData
import Combine
import LocalAuthentication

class AuthViewModel: ObservableObject {
    @Published var isUnlocked = false
    @Published var errorMessage: String? = nil

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // Verifica si la biometría está disponible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Autentícate para acceder a MisGastos"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        self.errorMessage = authenticationError?.localizedDescription ?? "Falló la autenticación"
                        self.isUnlocked = false
                    }
                }
            }
        } else {
            // Si no hay Face ID/Touch ID, desbloquea para no trabar al usuario
            DispatchQueue.main.async {
                self.errorMessage = "Biometría no disponible"
                self.isUnlocked = true
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var tabSelection = TabSelection()
    @StateObject var authManager = AuthManager()
    @AppStorage("useFaceID") private var useFaceID: Bool = false
    @StateObject private var authVM = AuthViewModel()

    @State private var currentTab: CustomTabs = .Home
    @State private var demoSearch: String = String()
    var body: some View {
        ZStack {
            if useFaceID && !authVM.isUnlocked {
                // Pantalla de bloqueo biométrico
                VStack {
                    Image(systemName: "faceid")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                        .padding()
                    Text("Autenticación requerida")
                        .font(.title2)
                        .padding(.bottom, 8)
                    if let error = authVM.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.vertical)
                    }
                    Button("Intentar de nuevo") {
                        authVM.authenticate()
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.9))
                .onAppear {
                    authVM.authenticate()
                }
            } else {
                if authManager.session != nil {
                    TabView(selection: $tabSelection.currentTab){
                        Tab("Inicio", systemImage: "house", value: .Home){
                            HomeView()
                        }
                        Tab("Presupuesto", systemImage: "wallet.bifold", value: .Budgets){
                            BudgetsView()
                        }
                        Tab("Nuevo", systemImage: "plus", value: .NewExpense){
                            AddOrUpdateExpense()
                        }
                        Tab("Ajustes", systemImage:"gear", value: .Config){
                            ConfigView()
                        }
                        Tab("Historial", systemImage:"magnifyingglass",value: .History, role: .search){
                            History()
                        }
                    }
                    .environmentObject(tabSelection)
                }
                else{
                    LoginView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

enum CustomTabs: String, CaseIterable, Hashable {
     case Home
     case Budgets
     case NewExpense
     case Config
     case History
}

class TabSelection: ObservableObject {
    @Published var currentTab: CustomTabs = .Home
}

extension String {
    func toLocalDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: self) ?? Date()
    }
}
