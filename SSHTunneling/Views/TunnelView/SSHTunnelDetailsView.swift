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
    @State var useNio: Bool = false
    @State var loadingDots = "..."
        
    var body: some View {
        VStack {
            Text(tunnel.config.name)
            VStack {
                Text("Status - \(tunnel.state.rawValue)\(tunnel.state == .connecting ? loadingDots : "")")
                    .animation(.default)
                    .transition(AnyTransition.scale(scale: 1.5).combined(with: .opacity))
            }
            Form {
                Section {
                    //Text("Tunnel name:")
                    TextField("Tunnel name:", text: $tunnel.config.name)
                    TextField("Username:", text: $tunnel.config.username)
                    TextField("IP Address:", text: $tunnel.config.serverIP)
                    TextField("Local port:", value: $tunnel.config.localPort, format: .number)
                    TextField("Server port:", value: $tunnel.config.distantPort, format: .number)
                    SecureInputView("Password:", text: $tunnel.config.password, disabled: $passwordAuthentication)
                    Toggle(isOn: $passwordAuthentication) {
                        Text("Use password")
                        Text("less secured")
                            .fontWeight(.light)
                    }
                    Toggle(isOn: $useNio) {
                        Text("Use NIO Library")
                        Text("Experimental")
                            .fontWeight(.light)
                    }
                }
            }
        
            Divider()
            if (!useNio) {
                HStack {
                    Text("Result SSH command for this tunnel:")
                    Text(tunnel.cmd ?? "config not applied")
                        .bold()
                        .italic()
                        .textSelection(.enabled)
                }
                Divider()
            }
            HStack {
                Button("Save", systemImage: "opticaldisc.fill") {
                    tunnel.updateConfig(config: tunnel.config)
                    tunnel.config.usePassword = passwordAuthentication
                    tunnel.config.useNio = useNio
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
            useNio = tunnel.config.useNio ?? false
        }
        .padding()
    }
}

struct SSHTunnelDetailsView_Previews: PreviewProvider {
   
    static var previews: some View {
        SSHTunnelDetailsView(tunnel: SSHTunnel(), updated: .constant(false))
    }
}
