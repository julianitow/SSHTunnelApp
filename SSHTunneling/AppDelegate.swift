//
//  AppDelegate.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 26/09/2023.
//

import Foundation
import AppKit
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var SSHTunnels: [SSHTunnel]!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
            return false
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if self.SSHTunnels.isEmpty { return }
        for tunnel in self.SSHTunnels {
            guard let index = ShellService.tasks.firstIndex(where: {$0.id == tunnel.taskId}) else { continue }
            if !ShellService.tasks[index].process.isRunning { continue }
            ShellService.tasks[index].process.terminate()
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let sshTunnelIndex = SSHTunnels.firstIndex(where: { return $0.taskId.uuidString == response.notification.request.identifier })
        if (sshTunnelIndex == nil) { return }
        let tunnel = SSHTunnels[sshTunnelIndex!]
        print(tunnel.config.name)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
}
