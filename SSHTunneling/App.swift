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
                    print(self.contentView.SSHTunnels.count)
                }
        }
        MenuBarExtra("SSH Tunneling", systemImage: "rectangle.connected.to.line.below") {
            VStack {
                ForEach(self.contentView.SSHTunnels, id: \.self.taskId) { tunnel in
                    Button(tunnel.name) {
                        if !tunnel.isConnected {
                            tunnel.connect()
                            return
                        }
                        tunnel.disconnect()
                    }
                }
            }
            Button("Quit")
            {
                NSApplication.shared.terminate(nil)
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                // REMOVE ICON FROM DOCK
            }
        }
    }
}
