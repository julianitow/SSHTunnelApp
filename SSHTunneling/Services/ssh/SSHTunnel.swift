//
//  SSHTunnel.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 24/09/2023.
//

import Foundation

//ssh ***REMOVED***@***REMOVED*** -Nf  -L 127.0.0.1:27018:127.0.0.1:27017

class SSHTunnel: Equatable, ObservableObject {
    
    public let taskId: UUID
    public var config: SSHTunnelConfig
    
    init(config: SSHTunnelConfig) {
        self.config = config
        let cmd = "ssh \(self.config.username)@\(self.config.serverIP) -N -L \(self.config.toIP):\(self.config.localPort):127.0.0.1:\(self.config.distantPort)"
        print(cmd)
        self.taskId = ShellService.createShellTask(cmd)
    }
    
    var isConnected: Bool {
        return ShellService.isRunning(id: self.taskId)
    }
    
    func connect(_ linkOutput: Bool? = false) -> Void {
        do {
            if ShellService.isSuspended(id: taskId) {
                if !ShellService.resumeTask(id: taskId) {
                    throw SSHTunnelError.ErrorResumingTask
                }
                return
            }
            try ShellService.runTask(taskId, linkOutput)
        } catch {
            print("SSHTunnel::connect::error => \(error)")
        }
    }
    
    func disconnect() -> Void {
        ShellService.suspendTask(id: self.taskId)
    }
    
    static func == (lhs: SSHTunnel, rhs: SSHTunnel) -> Bool {
        return lhs.taskId == rhs.taskId
    }
}
