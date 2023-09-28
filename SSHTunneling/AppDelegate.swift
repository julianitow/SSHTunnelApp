//
//  AppDelegate.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 26/09/2023.
//

import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var SSHTunnels: [SSHTunnel]!
    
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
    
    func tmp() -> Void {
        print("HERE")
    }
}
