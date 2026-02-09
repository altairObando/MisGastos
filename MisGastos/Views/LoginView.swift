//
//  LoginView.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 2/9/26.
//

import SwiftUI
import Supabase

struct LoginView: View {
    @State private var username: String = String()
    @State private var password: String = String()
    @State private var loading = false;
    @State private var showPasswordReseted = false
    // Estados para manejo de alertas
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertIsSuccess = false
    var body: some View {
        VStack(alignment: .center, spacing: 20 ){
            Image("DefaultIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            Text("Inicio de sesión")
                .font(.title.bold())
            CustomSection(String()){
                HStack{
                    Text("Usuario: ")
                    TextField("Usuario", text: $username)
                        .keyboardType(.emailAddress)
                        .foregroundStyle(.black)
                }.padding(.horizontal)
                .padding(.vertical, 10)
                SectionSeparator()
                HStack{
                    Text("Contraseña:")
                    SecureField("Contraseña", text: $password)
                        .foregroundStyle(.black)
                }.padding(.horizontal)
                    .padding(.vertical, 10)
            }
            Button("Iniciar Session", systemImage: "rectangle.portrait.and.arrow.right"){
                login()
            }.buttonStyle(.glassProminent)
            Button("Reestablecer Contraseña", systemImage: "key"){
                resetPassword()
            }.buttonStyle(.glass)
        }
        .foregroundStyle(.white)
        // Presentar alertas de error/éxito
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .padding()
        .globalBackground()
    }
    func login(){
        Task {
            do{
                if username.isEmpty || password.isEmpty{
                    alertTitle = "Campos incompletos"
                    alertMessage = "Por favor ingresa usuario y contraseña."
                    alertIsSuccess = false
                    showingAlert = true
                    return
                }
                loading = true;
                _ = try await SupabaseClient.shared.client.auth.signIn(email: username, password: password);
            } catch {
                // Mostrar mensaje de error al usuario
                let message = error.localizedDescription
                print("Sign in failed: \(message)")
                if message.contains("Email not confirmed") {
                    alertTitle = "Email no confirmado"
                    alertMessage = "Tu correo no ha sido confirmado. Revisa tu bandeja y confirma tu cuenta."
                } else if message.contains("already exists") {
                    alertTitle = "Cuenta existente"
                    alertMessage = "Ya existe una cuenta con ese correo. Intenta iniciar sesión o restablecer la contraseña."
                } else {
                    alertTitle = "Error"
                    alertMessage = message
                }
                alertIsSuccess = false
                showingAlert = true
            }
            loading = false;
        }
    }
    func resetPassword(){
        Task{
            do{
                if username.isEmpty {
                    alertTitle = "Campo vacío"
                    alertMessage = "Por favor ingresa el correo asociado a la cuenta."
                    alertIsSuccess = false
                    showingAlert = true
                    return
                }
                loading = true;
                try await SupabaseClient.shared.client.auth.resetPasswordForEmail(username)
                // Notificar éxito al usuario
                alertTitle = "Correo enviado"
                alertMessage = "Si existe una cuenta con ese correo recibirás instrucciones para restablecer la contraseña."
                alertIsSuccess = true
                showingAlert = true
            }catch{
                let message = error.localizedDescription
                print("Reset password failed: \(message)")
                alertTitle = "Error"
                alertMessage = message
                alertIsSuccess = false
                showingAlert = true
            }
            loading = false;
        }
    }
}

#Preview {
    LoginView()
}
