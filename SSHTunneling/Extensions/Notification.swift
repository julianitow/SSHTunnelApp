//
//  Notification.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 28/09/2023.
//

import Foundation

extension Notification.Name {
    static let newNotification = Notification.Name("newNotification")
}

extension Notification.Name {
    static let resetNotification = Notification.Name("resetNotification")
}

extension Notification.Name {
    static let updateNotification = Notification.Name("updateNotification")
}

extension Notification.Name {
    static let refreshNotification = Notification.Name("refreshNotification")
}

extension Notification.Name {
    static let processTerminateNotification = Notification.Name("processTerminateNotification")
}

extension Notification.Name {
    static let connectionErrorNotification = Notification.Name("connectionErrorNotification")
}
