//
//  AppMenu.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 27/09/2023.
//

import SwiftUI

struct AppMenu: View {

    public var tunnels: [SSHTunnel]!
    
    @State var btnIcons: [String] = []
    
    init(tunnels: [SSHTunnel]) {
        self.tunnels = tunnels
        var icons: [String] = []
        for _ in 0..<tunnels.count {
            icons.append("circle.dotted")
        }
        _btnIcons = State(initialValue: icons)
    }
    
    var body: some View {
        VStack {
            ForEach(0..<tunnels.count) { i in
                HStack {
                    Button(tunnels[i].name, systemImage: btnIcons[i]) {
                        if !tunnels[i].isConnected {
                            tunnels[i].connect()
                            btnIcons[i] = "circle.fill"
                            return
                        }
                        tunnels[i].disconnect()
                        btnIcons[i] = "circle.dotted"
                    }
                    .labelStyle(.titleAndIcon)
                }
            }
        }
        Button("Quit")
        {
            NSApplication.shared.terminate(nil)
        }
    }
    
}
