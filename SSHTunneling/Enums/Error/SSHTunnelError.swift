//
//  SSHTunnelError.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 27/09/2023.
//

import Foundation

enum SSHTunnelError: Error {
    case ErrorResumingTask
    case unexpected(code: Int)
}
