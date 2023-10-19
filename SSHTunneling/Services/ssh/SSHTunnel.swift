//
//  SSHTunnel.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 24/09/2023.
//

import Foundation

class SSHTunnel: Equatable, ObservableObject {
    
    public let id: UUID
    public var taskId: UUID
    public var config: SSHTunnelConfig
    public var cmd: String?
    public let fileManager = FileManager.default
        
    init(config: SSHTunnelConfig) {
        self.id = UUID()
        self.config = config
        if config.usePassword {
            if config.password.contains("$"){
                self.config.password = config.password.replacingOccurrences(of: "$", with: "\\\\$")
            }
            var scriptPath = Bundle.main.bundlePath
            scriptPath.append("/Contents/Resources/expect_ssh_password_authent.sh")
            if !fileManager.isExecutableFile(atPath: scriptPath) {
                do {
                    try fileManager.setAttributes([.posixPermissions: NSNumber(value: 0o755)], ofItemAtPath: scriptPath)
                } catch {
                    print("While chmod script : \(error)")
                }
            }
            self.cmd = "\(scriptPath) \(self.config.username) \(self.config.serverIP) \(self.config.distantPort) \(self.config.localPort) \(self.config.password)"
        } else {
            self.cmd = "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \(self.config.username)@\(self.config.serverIP) -N -L \(self.config.toIP):\(self.config.localPort):127.0.0.1:\(self.config.distantPort)"
        }
        self.taskId = ShellService.createShellTask(self.cmd!)
    }
    
    init() {
        self.id = UUID()
        self.config = SSHTunnelConfig(name: "New config", username: "", serverIP: "", to: "", localPort: 0, distantPort: 0)
        self.cmd = ""
        self.taskId = self.id
    }
    
    func setCommand() -> Void {
        print("CONNECT CALLED")
        if self.config.usePassword {
            if (self.config.password.contains("$") && !self.config.password.contains("\\$")){
                self.config.password = config.password.replacingOccurrences(of: "$", with: "\\\\$")
            }
            print(self.config.password)
            var scriptPath = Bundle.main.bundlePath
            scriptPath.append("/Contents/Resources/expect_ssh_password_authent.sh")
            self.cmd = "\(scriptPath) \(self.config.username) \(self.config.serverIP) \(self.config.distantPort) \(self.config.localPort) \(self.config.password)"
        } else {
            self.cmd = "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \(self.config.username)@\(self.config.serverIP) -N -L \(self.config.toIP):\(self.config.localPort):127.0.0.1:\(self.config.distantPort)"
        }
        self.taskId = ShellService.createShellTask(self.cmd!)
    }
    
    func updateConfig(config: SSHTunnelConfig) {
        self.config = config
        self.setCommand()
        //objectWillChange.send()
    }
    
    var isConnected: Bool {
        return ShellService.isRunning(id: self.taskId)
    }
    
    func connect(_ linkOutput: Bool? = false, password: String? = nil) -> Bool {
        do {
            /*if ShellService.isSuspended(id: taskId) {
                if !ShellService.resumeTask(id: taskId) {
                    throw SSHTunnelError.ErrorResumingTask
                }
            } else {
                
            }*/
            self.setCommand()
            try ShellService.runTask(taskId, linkOutput, input: password)
        } catch {
            print("SSHTunnel::connect::error => \(error)")
            self.setCommand()
            NotificationCenter.default.post(name: Notification.Name.connectionErrorNotification, object: self.id)
            return false
        }
        return true
    }
    
    func disconnect() -> Void {
        return ShellService.stopTask(id: self.taskId)
    }
    
    static func == (lhs: SSHTunnel, rhs: SSHTunnel) -> Bool {
        return lhs.id == rhs.id && rhs.config == lhs.config
    }
}
