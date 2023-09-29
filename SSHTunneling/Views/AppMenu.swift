//
//  AppMenu.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 27/09/2023.
//

import SwiftUI

struct AppMenu: View {

    public var tunnels: [SSHTunnel]!
    
    @Environment(\.openWindow) var openWindow
    @State var btnIcons: [String] = []
    @State var updated: Bool = false
    
    init(tunnels: [SSHTunnel]) {
        self.tunnels = tunnels
        var icons: [String] = []
        for _ in 0..<tunnels.count {
            icons.append("circle.dotted")
        }
        _btnIcons = State(initialValue: icons)
    }
    
    func openMainWindow() -> Void {
        NSApp.setActivationPolicy(.regular)
        DispatchQueue.main.async {
            let window = NSApp.windows.firstIndex(where: { $0.title == "SSHTunneling"})
            if window != nil {
                NSApp.windows.first?.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    var body: some View {
        VStack {
            ForEach(0..<tunnels.count) { i in
                HStack {
                    Button(tunnels[i].config.name, systemImage: btnIcons[i]) {
                        if !tunnels[i].isConnected {
                            if tunnels[i].connect() {
                                btnIcons[i] = "circle.fill"
                            }
                            return
                        }
                        tunnels[i].disconnect()
                        btnIcons[i] = "circle.dotted"
                    }
                    .labelStyle(.titleAndIcon)
                }
            }
        }
        Divider()
        Button("Open window") {
            openMainWindow()
        }
        Divider()
        Button("Quit")
        {
            NSApplication.shared.terminate(nil)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.processTerminateNotification), perform: { data in
            let id = data.object as? UUID
            guard let index = tunnels.firstIndex(where: { $0.taskId == id }) else { return }
            btnIcons[index] = "exclamationmark.triangle"
            openMainWindow()
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.connectionErrorNotification), perform: { data in
            let id = data.object as? UUID
            guard let index = tunnels.firstIndex(where: { $0.id == id }) else { return }
            btnIcons[index] = "exclamationmark.triangle"
            openMainWindow()
        })
    }
    
}