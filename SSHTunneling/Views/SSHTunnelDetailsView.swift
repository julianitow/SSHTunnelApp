//
//  TunnelDetailsView.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 28/09/2023.
//

import SwiftUI

struct SSHTunnelDetailsView: View {
    
    @State var tunnel: SSHTunnel
    
    init(tunnel: SSHTunnel) {
        self.tunnel = tunnel
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Tunnel name:")
                TextField("name", text: $tunnel.config.name)
            }
            HStack {
                Text("username:")
                TextField("username", text: $tunnel.config.username)
            }
            HStack {
                Text("Ip address:")
                TextField("", text: $tunnel.config.serverIP)
            }
            HStack {
                Text("Local port:")
                TextField("", value: $tunnel.config.localPort, format: .number)
            }
            
            HStack {
                Text("Server port:")
                TextField("", value: $tunnel.config.distantPort, format: .number)
            }
        }
    }
}
