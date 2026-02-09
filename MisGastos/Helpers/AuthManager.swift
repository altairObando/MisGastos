//
//  AuthManager.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 2/9/26.
//

import SwiftUI
import Supabase
import Combine

@MainActor
class AuthManager: ObservableObject {
    private var client = SupabaseClient.shared.client;
    @Published var session: Session? = nil
    
    init() {
        Task {
            self.session = try? await client.auth.session
            for await event in client.auth.authStateChanges {
                self.session = event.session
            }
        }
    }
}
