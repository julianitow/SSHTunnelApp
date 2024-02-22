//
//  SSHTunnelState.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 22/02/2024.
//

import Foundation

enum SSHTunnelState: String {
    case connecting = "Connecting"
    case connected = "Connected"
    case disconnected = "Disconnected"
}
