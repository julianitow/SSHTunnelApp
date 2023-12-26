//
//  AppMenu.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 27/09/2023.
//

import SwiftUI

struct AppMenu: View {

    @State private var updated: Bool = false
    @EnvironmentObject var viewModel: SSHTunnelsViewModel
    
    func openMainWindow() -> Void {
        NSApp.setActivationPolicy(.regular)
        DispatchQueue.main.async {
            let window = NSApp.windows.firstIndex(where: { $0.title == viewModel.selectedTunnel?.config.name ?? "SSHTunneling" })
            if window != nil {
                NSApp.windows.first?.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    var body: some View {
        VStack {
            ForEach(0..<viewModel.tunnels.count, id: \.self) { i in
                HStack {
                    Button(viewModel.tunnels[i].config.name, systemImage: viewModel.icons[i]) {
                        _ = viewModel.toggleConnection(for: viewModel.tunnels[i].id)
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
            if task.exitCode != 130 && task.exitCode != 0 {
                viewModel.icons[index] = "exclamationmark.triangle"
                //openMainWindow()
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.connectionErrorNotification), perform: { data in
            let id = data.object as? UUID
            guard let index = viewModel.tunnels.firstIndex(where: { $0.id == id }) else { return }
            viewModel.icons[index] = "exclamationmark.triangle"
            openMainWindow()
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.updateNotification), perform: { data in
            let action = data.object as? String
            guard let splitted = action?.split(separator: ":") else {
                return
            }
            if splitted[0] == "duplicateAction" {
                print("DUPLCATE ACTION")
            }
        })
    }
    
}
