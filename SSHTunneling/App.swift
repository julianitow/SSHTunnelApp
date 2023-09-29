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
    @StateObject var viewModel = SSHTunnelsViewModel()
    
    var contentView: ContentView
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init() {
        self.contentView = ContentView()
    }
    

    var body: some Scene {
        Window("SSHTunneling", id: "main-window") {
            self.contentView
                .environmentObject(viewModel)
                .onAppear {
                    self.appDelegate.SSHTunnels = self.contentView.SSHTunnels
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New tunnel") {
                    NotificationCenter.default.post(name: Notification.Name.newNotification, object: "")
                }
                Button("Reset configs") {
                    NotificationCenter.default.post(name: Notification.Name.resetNotification, object: "resetConfig")
                }
            }
            CommandGroup(replacing: .saveItem) {
                EmptyView()
            }
            CommandGroup(replacing: .printItem) {
                EmptyView()
            }
            CommandGroup(replacing: .undoRedo) {
                EmptyView()
            }
            CommandGroup(replacing: .pasteboard) {
                EmptyView()
            }
        }
        MenuBarExtra("SSH Tunneling", systemImage: "rectangle.connected.to.line.below") {
            AppMenu(tunnels: self.contentView.SSHTunnels)
                .environmentObject(viewModel)
        }
        .menuBarExtraStyle(.menu)
    }
}
