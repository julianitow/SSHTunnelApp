//
//  ContentView.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 21/09/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var exitCode: Int32 = 0
    var SSHTunnels: [SSHTunnel] = []
    
    mutating func createTunnels() {
        let tunnelBeta = SSHTunnel(name: "BETA", username: "***REMOVED***", serverIP: "***REMOVED***", to: "127.0.0.1", localPort: 27018, distantPort: 27017)
        let tunnelProd = SSHTunnel(name: "PROD-1", username: "***REMOVED***", serverIP: "***REMOVED***", to: "127.0.0.1", localPort: 27019, distantPort: 27017)
        self.SSHTunnels.append(tunnelBeta)
        self.SSHTunnels.append(tunnelProd)
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
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(String(exitCode))
        }
        .padding()
        .task {
            //self.run()
        }
    }
}

/**struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}**/
