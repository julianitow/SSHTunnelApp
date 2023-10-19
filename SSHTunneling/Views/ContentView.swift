//
//  ContentView.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 21/09/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var exitCode: Int32 = 0
    @EnvironmentObject var viewModel: SSHTunnelsViewModel
    @State var updated: Bool = false
    
    var SSHTunnels: [SSHTunnel] = []
    
    mutating func createTunnels() {
        do {
            let configs = try StorageService.getConfigs()
            for config in configs {
                print(config)
                self.SSHTunnels.append(SSHTunnel(config: config))
            }
        } catch {
            print("\(error)")
        }
    }
    
    init() {
        self.createTunnels()
    }
    
    mutating func newConfig() -> Void {
        self.SSHTunnels.append(SSHTunnel())
    }
    
    func removeConfigFor(tunnel: SSHTunnel) -> Void {
        guard let index = self.viewModel.tunnels.firstIndex(where: { $0.id == tunnel.id }) else { return }
        self.viewModel.tunnels.remove(at: index)
        StorageService.removeConfig(config: tunnel.config)
    }
    
    func duplicateConfigFor(tunnel: SSHTunnel) -> Void {
        let duplicatedConfig = SSHTunnelConfig.duplicate(from: tunnel.config)
        StorageService.saveConfig(config: duplicatedConfig)
        self.viewModel.tunnels.append(SSHTunnel(config: duplicatedConfig))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tunnels, id: \.self.taskId) { tunnel in
                    NavigationLink(tunnel.config.name) {
                        SSHTunnelDetailsView(tunnel: tunnel, updated: $updated)
                    }
                    .contextMenu {
                        VStack {
                            Button("Duplicate") {
                                self.duplicateConfigFor(tunnel: tunnel)
                            }
                            .disabled(true)
                            Divider()
                            Button("Remove") {
                                self.removeConfigFor(tunnel: tunnel)
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            Text("No selection")
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.newNotification), perform: { _ in
            self.viewModel.tunnels.append(SSHTunnel())
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.updateNotification), perform: { data in
            let action = data.object as? String
            guard let splitted = action?.split(separator: ":") else {
                return
            }
            if splitted[0] == "removeAction" {
                guard let id = UUID(uuidString: String(splitted[1])) else { return }
                guard let tunnel = self.viewModel.tunnels.first(where: { $0.id == id }) else { return }
                self.removeConfigFor(tunnel: tunnel)
                self.viewModel.selectedId = nil
            } else if splitted[0] == "duplicateAction" {
                guard let id = UUID(uuidString: String(splitted[1])) else { return }
                guard let tunnel = self.viewModel.tunnels.first(where: { $0.id == id }) else { return }
                self.duplicateConfigFor(tunnel: tunnel)
            }
            viewModel.objectWillChange.send()
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.resetNotification), perform: { _ in
            StorageService.erase()
        })
        .onAppear() {
            self.viewModel.tunnels = self.SSHTunnels
        }
    }
}

/**struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}**/
