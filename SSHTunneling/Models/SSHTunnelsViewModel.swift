//
//  SSHTunnelViewModel.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 28/09/2023.
//

import Foundation

final class SSHTunnelsViewModel: ObservableObject {
    
    @Published var tunnels: [SSHTunnel]
    @Published var selectedId: UUID?
    
    init(tunnels: [SSHTunnel] = []) {
        self.tunnels = tunnels
    }
}
