//
//  SSHTunnelConfig.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 28/09/2023.
//

import Foundation

struct SSHTunnelConfig: Codable {
    
    public var id: UUID
    public var name: String
    public var serverIP: String
    public var toIP: String
    public var localPort: Int
    public var distantPort: Int
    public var username: String
    
    init(name: String, username: String, serverIP: String, to: String, localPort: Int, distantPort: Int) {
        self.id = UUID()
        self.name = name
        self.serverIP = serverIP
        self.toIP = to
        self.localPort = localPort
        self.distantPort = distantPort
        self.username = username
    }
}
