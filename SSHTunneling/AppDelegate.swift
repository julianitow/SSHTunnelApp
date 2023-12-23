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
    private var window: NSWindow?
    var viewModel: SSHTunnelsViewModel?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        if let window = NSApplication.shared.windows.first {
            window.close()
            self.window = window
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
            return false
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        guard let _ = self.viewModel else { return }
        if self.viewModel?.tunnels.count == 0 { return }
        for tunnel in self.viewModel!.tunnels {
            guard let index = ShellService.tasks.firstIndex(where: {$0.id == tunnel.taskId}) else { continue }
            if !ShellService.tasks[index].process.isRunning { continue }
            ShellService.tasks[index].process.terminate()
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let _ = self.viewModel else { return }
        self.viewModel?.selectedTunnel = self.viewModel?.tunnels.first(where: { $0.taskId.uuidString == response.notification.request.identifier})
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
}
