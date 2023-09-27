//
//  SSHTunnelError.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 27/09/2023.
//

import Foundation

extension SSHTunnelError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .ErrorResumingTask:
            return NSLocalizedString("Error resuming task", comment: "Unkown error, maybe task was not running")
        case .unexpected(_):
            return NSLocalizedString("An unexpected error occurred.", comment: "Unexpected Error")
        }
    }
}
