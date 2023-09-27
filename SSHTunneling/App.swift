//
//  SSHTunnelingApp.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 21/09/2023.
//

import SwiftUI

@main
struct SSHTunnelingApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    let contentView: ContentView
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init() {
        self.contentView = ContentView()
    }
    

    var body: some Scene {
        WindowGroup {
            self.contentView
                .onAppear {
                    self.appDelegate.SSHTunnels = self.contentView.SSHTunnels
                }
        }
        MenuBarExtra("SSH Tunneling", systemImage: "rectangle.connected.to.line.below") {
            AppMenu(tunnels: self.contentView.SSHTunnels)
        }
        .menuBarExtraStyle(.menu)
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                // REMOVE ICON FROM DOCK
            }
        }
    }
}
