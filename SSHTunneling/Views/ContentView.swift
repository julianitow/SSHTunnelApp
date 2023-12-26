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
    @State var newConfigForm: Bool = false
    @StateObject var newTunnel: SSHTunnel = SSHTunnel()
    
    @State var SSHTunnels: [SSHTunnel] = []
    
    @State private var selection: SSHTunnel?
    
    init() {
        do {
            let configs = try StorageService.getConfigs()
            self._SSHTunnels = State(initialValue: configs.map { SSHTunnel(config: $0) })
        } catch {
            print("\(error)")
        }
    }
    
    func removeConfigFor(tunnel: SSHTunnel) -> Void {
        guard let index = self.viewModel.tunnels.firstIndex(where: { $0.id == tunnel.id }) else { return }
        self.viewModel.removeTunnel(at: index)
        StorageService.removeConfig(config: tunnel.config)
    }
    
    func duplicateConfigFor(tunnel: SSHTunnel) -> Void {
        let duplicatedConfig = SSHTunnelConfig.duplicate(from: tunnel.config)
        StorageService.saveConfig(config: duplicatedConfig)
        self.viewModel.newTunnel(SSHTunnel(config: duplicatedConfig))
    }
    
    var body: some View {
        NavigationSplitView {
            List(viewModel.tunnels, id: \.self, selection: $viewModel.selectedTunnel) { tunnel in
                NavigationLink(value: tunnel) {
                    Text(tunnel.config.name)
                }
                .contextMenu {
                    VStack {
                        Button("Duplicate") {
                            self.duplicateConfigFor(tunnel: tunnel)
                        }
                        Divider()
                        Button("Remove") {
                            self.removeConfigFor(tunnel: tunnel)
                        }
                    }
                }
            }
        } detail: {
            NavigationStack {
                ZStack {
                    if viewModel.selectedTunnel != nil{
                        SSHTunnelDetailsView(tunnel: viewModel.selectedTunnel!, updated: $updated)
                            .id(viewModel.selectedTunnel!.id)
                    } else {
                        Text("No config selected")
                    }
                }
            }
            .navigationTitle(viewModel.selectedTunnel?.config.name ?? "SSHTunneling")
            .toolbar {
                if (viewModel.selectedTunnel != nil) {
                    Button("Connect", systemImage: viewModel.selectedTunnel!.isConnected ? "stop.fill" : "play.fill") {
                        _ = self.viewModel.toggleConnection(for: viewModel.selectedTunnel!.id)
                    }
                }
            }
        }
        .onAppear() {
            self.viewModel.newTunnels(tunnels: SSHTunnels)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.updateNotification), perform: { data in
            let action = data.object as? String
            guard let splitted = action?.split(separator: ":") else {
                return
            }
            if splitted[0] == "removeAction" {
                guard let id = UUID(uuidString: String(splitted[1])) else { return }
                guard let tunnel = self.viewModel.tunnels.first(where: { $0.id == id }) else { return }
                self.removeConfigFor(tunnel: tunnel)
                self.viewModel.selectedTunnel = nil
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
    }
}

/**struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}**/
