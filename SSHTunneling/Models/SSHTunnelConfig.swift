//
//  SSHTunnelConfig.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 28/09/2023.
//

import Foundation

class SSHTunnelConfig: Codable, Equatable, ObservableObject, CustomStringConvertible {
    
    public var id: UUID
    public var name: String
    public var serverIP: String
    public var toIP: String
    public var localPort: Int
    public var distantPort: Int
    public var username: String
    public var usePassword: Bool
    public var password: String = ""
    public var useNio: Bool? //optional because of old configurations might not containing this attribute during decoding saved configs
    
    public var description: String {
        return " ################\n id: \(id)\n name: \(self.name)\n serverIP: \(self.serverIP)\n toIp: \(self.toIP)\n localPort: \(localPort)\n distantPort: \(self.distantPort)\n username: \(self.username)\n usePassword: \(self.usePassword)\n useNio: \(self.useNio ?? false)"
    }
    
    init(name: String, username: String, serverIP: String, to: String, localPort: Int, distantPort: Int) {
        self.id = UUID()
        self.name = name
        self.serverIP = serverIP
        self.toIP = to
        self.localPort = localPort
        self.distantPort = distantPort
        self.username = username
        self.usePassword = false
        self.useNio = false
    }
    
    static func duplicate(from: SSHTunnelConfig) -> SSHTunnelConfig {
        return SSHTunnelConfig(name: "\(from.name) - copy", username: from.username, serverIP: from.serverIP, to: from.toIP, localPort: from.localPort, distantPort: from.distantPort)
    }
    
    static func == (lhs: SSHTunnelConfig, rhs: SSHTunnelConfig) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.serverIP == rhs.serverIP && lhs.toIP == rhs.toIP && lhs.localPort == rhs.localPort && lhs.distantPort == rhs.distantPort && lhs.username == rhs.username
    }
}
