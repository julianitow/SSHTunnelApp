//
//  ContentView.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 21/09/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var exitCode: Int32 = 0
    @StateObject var viewModel = SSHTunnelViewModel()
    
    var SSHTunnels: [SSHTunnel] = []
    
    mutating func createTunnels() {
        let tunnelBeta = SSHTunnelConfig(name: "BETA", username: "***REMOVED***", serverIP: "***REMOVED***", to: "127.0.0.1", localPort: 27018, distantPort: 27017)
        let tunnelProd = SSHTunnelConfig(name: "PROD-1", username: "***REMOVED***", serverIP: "***REMOVED***", to: "127.0.0.1", localPort: 27019, distantPort: 27017)
        let tunnelProd2 = SSHTunnelConfig(name: "PROD-2", username: "***REMOVED***", serverIP: "***REMOVED***", to: "127.0.0.1", localPort: 27020, distantPort: 27017)
        let tunnelProd3 = SSHTunnelConfig(name: "PROD-3", username: "***REMOVED***", serverIP: "***REMOVED***", to: "127.0.0.1", localPort: 27021, distantPort: 27017)
        /*self.SSHTunnels.append(SSHTunnel(config: tunnelBeta))
        self.SSHTunnels.append(SSHTunnel(config: tunnelProd))
        self.SSHTunnels.append(SSHTunnel(config: tunnelProd2))
        self.SSHTunnels.append(SSHTunnel(config: tunnelProd3))*/
        
        //StorageService.saveConfig(config: tunnelBeta)
                
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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(SSHTunnels, id: \.self.taskId) { tunnel in
                    NavigationLink(tunnel.config.name, tag: tunnel.taskId, selection: $viewModel.selectedId) {
                        SSHTunnelDetailsView(tunnel: tunnel)
                    }
                }
            }
            .listStyle(.sidebar)
            Text("No selection")
        }
        /*VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(String(exitCode))
        }
        .padding()
        .task {
            //self.run()
        }*/
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
