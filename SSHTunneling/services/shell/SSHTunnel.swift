//
//  SSHTunnel.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 24/09/2023.
//

import Foundation

//ssh ***REMOVED***@***REMOVED*** -Nf  -L 127.0.0.1:27018:127.0.0.1:27017

class SSHTunnel: Equatable {
    public let taskId: UUID
    public let name: String
    
    private let serverIP: String
    private let toIP: String
    private let localPort: Int
    private let distantPort: Int
    private let username: String
    
    init(name: String, username: String, serverIP: String, to: String, localPort: Int, distantPort: Int) {
        self.name = name
        self.serverIP = serverIP
        self.toIP = to
        self.localPort = localPort
        self.distantPort = distantPort
        self.username = username
        let cmd = "ssh \(self.username)@\(self.serverIP) -N -L \(self.toIP):\(self.localPort):127.0.0.1:\(self.distantPort)"
        print(cmd)
        self.taskId = ShellService.createShellTask(cmd)
    }
    
    var isConnected: Bool {
        return ShellService.isRunning(id: self.taskId)
    }
    
    func connect(_ linkOutput: Bool? = false) -> Void {
        do {
            if ShellService.isSuspended(id: taskId) {
                print("TASK SUSPENDED")
                ShellService.resumeTask(id: taskId)
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
