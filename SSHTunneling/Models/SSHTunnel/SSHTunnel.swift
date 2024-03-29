//
//  SSHTunnel.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 24/09/2023.
//

import Foundation

class SSHTunnel: Equatable, ObservableObject, Hashable {
    
    public let id: UUID
    public var taskId: UUID
    public var config: SSHTunnelConfig
    public var cmd: String?
    public let fileManager = FileManager.default
    public var state: SSHTunnelState = .disconnected
    private var SSHClient: NIOSSHClient?
    private let queue = DispatchQueue(label: "bg", qos: .background)
        
    init(config: SSHTunnelConfig) {
        self.id = UUID()
        self.config = config
        if (!(config.useNio ?? false)) {
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
            return
        }
        self.taskId = self.id
        self.SSHClient = NIOSSHClient(id: self.id)
        self.SSHClient!.setConfig(config: self.config)
    }
    
    init() {
        self.id = UUID()
        self.config = SSHTunnelConfig(name: "New config", username: "", serverIP: "", to: "", localPort: 0, distantPort: 0)
        self.cmd = ""
        self.taskId = self.id
    }
    
    func setCommand() -> Void {
        if self.config.usePassword {
            if (self.config.password.contains("$") && !self.config.password.contains("\\$")){
                self.config.password = config.password.replacingOccurrences(of: "$", with: "\\\\$")
            }
            if (self.config.password.contains("'") && !self.config.password.contains("\'")){
                self.config.password = config.password.replacingOccurrences(of: "'", with: "\'")
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
        if(!(config.useNio ?? false)) {
            self.setCommand()
        }
        //objectWillChange.send()
    }
    
    var isConnected: Bool {
        let useNio = self.config.useNio ?? false
        if (!useNio) { return ShellService.isRunning(id: self.taskId) }
        return self.SSHClient?.isConnected ?? false
    }
    
    func connect() -> Bool {
        self.state = .connecting
        let useNio = self.config.useNio ?? false
        if (!useNio) { return self._legacy_connect() }
        return nioConnect()
    }
    
    func nioConnect() -> Bool {
        if (self.SSHClient == nil) {
            self.SSHClient = NIOSSHClient(id: self.id)
        }
        self.SSHClient?.setConfig(config: self.config)
        self.queue.async {
            _ = self.SSHClient!.listen()
        }
        return true
        //return client.listen()
    }
    
    func _legacy_connect(_ linkOutput: Bool? = false, password: String? = nil) -> Bool {
        do {
            /*if ShellService.isSuspended(id: taskId) {
                if !ShellService.resumeTask(id: taskId) {
                    throw SSHTunnelError.ErrorResumingTask
                }
            } else {
                
            }*/
            self.setCommand()
            try ShellService.runTask(taskId, linkOutput, input: password)
            NotificationCenter.default.post(name: Notification.Name.connectionNotification, object: self.id)
            self.state = .connected
        } catch {
            print("SSHTunnel::connect::error => \(error)")
            self.setCommand()
            NotificationCenter.default.post(name: Notification.Name.connectionErrorNotification, object: self.id)
            self.state = .disconnected
            return false
        }
        return true
    }
    
    func disconnect() -> Void {
        self.state = .disconnected
        let useNio = self.config.useNio ?? false
        if (!useNio) { return self._legacy_disconnect() }
        return nioDisconnect()
    }
    
    func nioDisconnect() -> Void {
        self.SSHClient?.disconnect()
    }
    
    func _legacy_disconnect() -> Void {
        return ShellService.stopTask(id: self.taskId)
    }
    
    static func == (lhs: SSHTunnel, rhs: SSHTunnel) -> Bool {
        return lhs.id == rhs.id && rhs.config == lhs.config
    }
    
    func hash(into hasher: inout Hasher) -> Void {
        hasher.combine(id)
    }
}
