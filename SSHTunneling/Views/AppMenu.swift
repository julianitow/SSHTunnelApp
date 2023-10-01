//
//  AppMenu.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 27/09/2023.
//

import SwiftUI

struct AppMenu: View {

    @State public var tunnels: [SSHTunnel] = []
    
    @State var btnIcons: [String] = []
    @State private var updated: Bool = false
    
    @EnvironmentObject var viewModel: SSHTunnelsViewModel
    
    init(tunnels: [SSHTunnel]) {
        self.tunnels = tunnels
        var icons: [String] = []
        for _ in 0..<tunnels.count {
            icons.append("circle.dotted")
        }
        _btnIcons = State(initialValue: icons)
        _updated = State(initialValue: false)
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
    
    func refreshIcons() -> Void {
        var icons: [String] = []
        for _ in 0..<viewModel.tunnels.count {
            icons.append("circle.dotted")
        }
        self.btnIcons = icons
    }
    
    var body: some View {
        VStack {
            ForEach(0..<viewModel.tunnels.count, id: \.self) { i in
                HStack {
                    Button(viewModel.tunnels[i].config.name, systemImage: btnIcons[i]) {
                        if !viewModel.tunnels[i].isConnected {
                            if viewModel.tunnels[i].connect() {
                                btnIcons[i] = "circle.fill"
                            }
                            return
                        }
                        viewModel.tunnels[i].disconnect()
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
            guard let index = viewModel.tunnels.firstIndex(where: { $0.taskId == id }) else { return }
            guard let task = ShellService.tasks.first(where: {$0.id == viewModel.tunnels[index].taskId}) else { return }
            if !viewModel.tunnels[index].config.usePassword && task.exitCode != 130 && task.exitCode != 0 {
                btnIcons[index] = "exclamationmark.triangle"
                openMainWindow()
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.connectionErrorNotification), perform: { data in
            let id = data.object as? UUID
            guard let index = viewModel.tunnels.firstIndex(where: { $0.id == id }) else { return }
            btnIcons[index] = "exclamationmark.triangle"
            openMainWindow()
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.newNotification), perform: { data in
            self.btnIcons.append("circle.dotted")
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.updateNotification), perform: { data in
            let action = data.object as? String
            guard let splitted = action?.split(separator: ":") else {
                return
            }
            if splitted[0] == "duplicateAction" {
                self.refreshIcons()
            }
        })
        .onAppear {
            self.refreshIcons()
        }
    }
    
}
