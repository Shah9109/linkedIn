//
//  linkedInApp.swift
//  linkedIn
//
//  Created by Sanjay Shah on 21/07/25.
//

import SwiftUI

@main
struct ProNetApp: App {
    @StateObject private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
        }
    }
}
