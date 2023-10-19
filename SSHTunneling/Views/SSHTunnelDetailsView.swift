//
//  TunnelDetailsView.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 28/09/2023.
//

import SwiftUI

struct SSHTunnelDetailsView: View {
    
    @StateObject var tunnel: SSHTunnel
    @Binding var updated: Bool
    @State var passwordAuthentication: Bool = false
    
    var body: some View {
        VStack {
            Text(tunnel.config.name)
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
            HStack {
                Text("Authentication:")
                Toggle(isOn: $passwordAuthentication) {
                    Text("Use password")
                    Text("less secured")
                        .fontWeight(.light)
                }
                SecureInputView("password", text: $tunnel.config.password, disabled: $passwordAuthentication)
            }
            Divider()
            HStack {
                Text("Result SSH command for this tunnel:")
                Text(tunnel.cmd ?? "config not applied")
                    .bold()
                    .italic()
                    .textSelection(.enabled)
            }
            Divider()
            HStack {
                Button("Save", systemImage: "opticaldisc.fill") {
                    tunnel.updateConfig(config: tunnel.config)
                    tunnel.config.usePassword = passwordAuthentication
                    StorageService.updateConfig(config: tunnel.config)
                    self.updated.toggle()
                    NotificationCenter.default.post(name: Notification.Name.updateNotification, object: "updateAction:\(tunnel.id)")
                }
                .background(.green, in: .buttonBorder)
                .disabled(tunnel.isConnected)
                Button("Duplicate", systemImage: "doc.on.doc") {
                    self.updated.toggle()
                    NotificationCenter.default.post(name: Notification.Name.updateNotification, object: "duplicateAction:\(tunnel.id)")
                }
                .background(.blue, in: .buttonBorder)
                Button("Delete", systemImage: "trash.fill") {
                    self.updated.toggle()
                    NotificationCenter.default.post(name: Notification.Name.updateNotification, object: "removeAction:\(tunnel.id)")
                }
                .background(.red, in: .buttonBorder)
                .disabled(tunnel.isConnected)
            }
        }
        .onAppear {
            passwordAuthentication = tunnel.config.usePassword
        }
        .padding()
    }
}
