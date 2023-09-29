//
//  SSHTunnel.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 24/09/2023.
//

import Foundation

//ssh ***REMOVED***@***REMOVED*** -Nf  -L 127.0.0.1:27018:127.0.0.1:27017

class SSHTunnel: Equatable, ObservableObject {
    
    public let id: UUID
    public var taskId: UUID
    var config: SSHTunnelConfig
    public var cmd: String?
        
    init(config: SSHTunnelConfig) {
        self.id = UUID()
        self.config = config
        let cmd = "ssh \(self.config.username)@\(self.config.serverIP) -N -L \(self.config.toIP):\(self.config.localPort):127.0.0.1:\(self.config.distantPort)"
        self.cmd = cmd
        self.taskId = ShellService.createShellTask(cmd)
    }
    
    init() {
        self.id = UUID()
        self.config = SSHTunnelConfig(name: "New config", username: "", serverIP: "", to: "", localPort: 0, distantPort: 0)
        self.cmd = ""
        self.taskId = self.id
    }
    
    func setCommand() -> Void {
        let cmd = "ssh \(self.config.username)@\(self.config.serverIP) -N -L \(self.config.toIP):\(self.config.localPort):127.0.0.1:\(self.config.distantPort)"
        self.cmd = cmd
        self.taskId = ShellService.createShellTask(cmd)
    }
    
    func updateConfig(config: SSHTunnelConfig) {
        self.config = config
        self.setCommand()
        //objectWillChange.send()
    }
    
    var isConnected: Bool {
        return ShellService.isRunning(id: self.taskId)
    }
    
    func connect(_ linkOutput: Bool? = false) -> Bool {
        do {
            if ShellService.isSuspended(id: taskId) {
                if !ShellService.resumeTask(id: taskId) {
                    throw SSHTunnelError.ErrorResumingTask
                }
                return true
            }
            try ShellService.runTask(taskId, linkOutput)
        } catch {
            print("SSHTunnel::connect::error => \(error)")
            self.setCommand()
            NotificationCenter.default.post(name: Notification.Name.connectionErrorNotification, object: self.id)
            return false
        }
        return true
    }
    
    func disconnect() -> Void {
        ShellService.suspendTask(id: self.taskId)
    }
    
    static func == (lhs: SSHTunnel, rhs: SSHTunnel) -> Bool {
        return lhs.id == rhs.id && rhs.config == lhs.config
    }
}
