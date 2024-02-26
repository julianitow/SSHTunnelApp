//
//  SSHClientError.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 26/02/2024.
//

import Foundation

enum SSHClientError: Error {
    case passwordAuthenticationNotSupported
    case commandExecFailed
    case invalidChannelType
    case invalidData
    case badCredentials
    case authenticationFailed
}
