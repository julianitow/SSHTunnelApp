//
//  SSHTunnelViewModel.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 28/09/2023.
//

import Foundation

final class SSHTunnelsViewModel: ObservableObject {
    
    @Published var tunnels: [SSHTunnel]
    @Published var icons: [String]
    @Published var selectedTunnel: SSHTunnel?
    
    init(tunnels: [SSHTunnel] = []) {
        self.tunnels = tunnels
        self.icons = Array(repeating: "circle.dotted", count: tunnels.count)
    }
    
    func toggleConnection(for tunnelId: UUID) -> Bool? {
        guard let tunnel = self.tunnels.first(where: { $0.id == tunnelId }) else { return nil }
        if (tunnel.isConnected) {
            tunnel.disconnect()
            self.icons[self.tunnels.firstIndex(where: { $0.id == tunnel.id})!] = "circle.dotted"
            return false
        } else {
            _ = tunnel.connect()
            self.icons[self.tunnels.firstIndex(where: { $0.id == tunnel.id})!] = "circle.fill"
            return true
        }
    }
    
    func newTunnel() -> Void {
        self.tunnels.append(SSHTunnel())
        self.icons.append("circle.dotted")
    }
    
    func newTunnel(_ tunnel: SSHTunnel) -> Void {
        self.tunnels.append(tunnel)
        self.icons.append("circle.dotted")
    }
    
    func removeTunnel(at index: Int) -> Void {
        self.tunnels.remove(at: index)
        self.icons.remove(at: index)
    }
    
    func newTunnels(tunnels: [SSHTunnel]) -> Void {
        self.tunnels = tunnels
        self.icons = Array(repeating: "circle.dotted", count: tunnels.count)
    }
}
