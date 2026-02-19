//
//  ThunderpickMoveApp.swift
//  ThunderpickMove
//
//  Created by Maksim Kosharny on 19.02.2026.
//

import SwiftUI

@main
struct ThunderpickMoveApp: App {
    @StateObject private var viewModel = ViewModelTM()

    var body: some Scene {
        WindowGroup {
            SplashViewTM()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
