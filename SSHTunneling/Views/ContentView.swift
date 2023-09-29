//
//  ContentView.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 21/09/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var exitCode: Int32 = 0
    //@StateObject var viewModel = SSHTunnelsViewModel()
    @EnvironmentObject var viewModel: SSHTunnelsViewModel
    @State var updated: Bool = false
    
    var SSHTunnels: [SSHTunnel] = []
    
    mutating func createTunnels() {
        do {
            let configs = try StorageService.getConfigs()
            for config in configs {
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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tunnels, id: \.self.taskId) { tunnel in
                    NavigationLink(tunnel.config.name, tag: tunnel.id, selection: $viewModel.selectedId) {
                        SSHTunnelDetailsView(tunnel: tunnel, updated: $updated)
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
                guard let index = self.viewModel.tunnels.firstIndex(where: { $0.id == id }) else { return }
                self.viewModel.tunnels.remove(at: index)
                self.viewModel.selectedId = nil
            } else if splitted[0] == "duplicateAction" {
                guard let id = UUID(uuidString: String(splitted[1])) else { return }
                guard let index = self.viewModel.tunnels.firstIndex(where: { $0.id == id }) else { return }
                let duplicatedConfig = SSHTunnelConfig.duplicate(from: self.viewModel.tunnels[index].config)
                StorageService.saveConfig(config: duplicatedConfig)
                self.viewModel.tunnels.append(SSHTunnel(config: duplicatedConfig))
            }
            print(self.SSHTunnels.count)
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
