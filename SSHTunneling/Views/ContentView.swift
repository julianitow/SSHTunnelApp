//
//  ContentView.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 21/09/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var exitCode: Int32 = 0
    @StateObject var viewModel = SSHTunnelsViewModel()
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
    
    
    
    func run() {
        for tunnel in self.SSHTunnels {
            DispatchQueue.global(qos: .background).async {
                tunnel.connect()
                self.exitCode = ShellService.tasks.first(where: {$0.id == tunnel.taskId})!.exitCode
            }
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
                            .onChange(of: updated) {
                                viewModel.objectWillChange.send()
                            }
                    }
                    .onChange(of: tunnel) {
                        print("CONFIG UPDATED")
                    }
                }
            }
            .listStyle(.sidebar)
            Text("No selection")
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.newNotification), perform: { _ in
            self.viewModel.tunnels.append(SSHTunnel())
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
