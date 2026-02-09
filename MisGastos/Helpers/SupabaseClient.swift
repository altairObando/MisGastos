//
//  SupabaseClient.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 2/3/26.
//

import Foundation
import Supabase
import UIKit

class SupabaseClient {
    static let shared = SupabaseClient()
    let supabaseURL: URL
    let supabaseKey: String
    let client: Supabase.SupabaseClient

    private init() {
        self.supabaseURL = URL(string: "https://ezrgvioazqzmcnejdcax.supabase.co")!
        self.supabaseKey = "sb_publishable_cUfI40t4tszyWkXmPjTntQ_jIRMkcw1"
        let options = SupabaseClientOptions(auth: .init(emitLocalSessionAsInitialSession: true))
        self.client = Supabase.SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey, options: options)
    }
}
