//
//  shellService.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 21/09/2023.
//

import Foundation

struct ShellTask {
    var id: UUID
    var process: Process
    var pipe: Pipe
    var inputPipe: Pipe
    var output: String?
    var exitCode: Int32 = 0
    var isSuspended: Bool = false
    
    init(_ process: Process, _ pipe: Pipe, _ inputPipe: Pipe) {
        self.id = UUID.init()
        self.process = process
        self.pipe = pipe
        self.inputPipe = inputPipe
    }
}

class ShellService {
    static var tasks: [ShellTask] = []
    
    /*
     * Returns the index of the created ShellTask
     */
    static func createShellTask(_ command: String) -> UUID {
        let process = Process()
        let pipe = Pipe()
        let inputPipe = Pipe()
        
        process.standardOutput = pipe
        process.standardError = pipe
        process.standardInput = inputPipe
        process.arguments = ["-c", command]
        process.executableURL = URL(filePath: "/bin/zsh")
        process.terminationHandler = terminationHander
        process.qualityOfService = .utility
        
        let shellTask = ShellTask(process, pipe, inputPipe)
                
        tasks.append(shellTask)
        
        return shellTask.id
    }
    
    static func isRunning(id: UUID) -> Bool {
        for task in tasks where task.id == id {
            print(task.process.isRunning)
            return task.process.isRunning
        }
        return false
    }
    
    static func isSuspended(id: UUID) -> Bool {
        for task in tasks where task.id == id {
            return task.isSuspended
        }
        return false
    }
    
    static func resumeTask(id: UUID) -> Bool {
        guard let index = tasks.firstIndex(where: {$0.id == id}) else { print("TASK ID NOT FOUND"); return false}
        tasks[index].isSuspended = false
        return tasks[index].process.resume()
    }
    
    static func terminationHander(process: Process) -> Void {
        print("Exit code =>", process.terminationStatus)
        guard let index = tasks.firstIndex(where: { $0.process.processIdentifier == process.processIdentifier })
        else {
            return
        }
        tasks[index].exitCode = process.terminationStatus
        DispatchQueue.main.sync {
            NotificationCenter.default.post(name: Notification.Name.processTerminateNotification, object: tasks[index].id)
        }
    }
    
    static func suspendTask(id: UUID) -> Void {
        guard let index = tasks.firstIndex(where: {$0.id == id}) else { print("TASK ID NOT FOUND"); return }
        tasks[index].isSuspended = tasks[index].process.suspend()
    }
    
    static func stopTask(id: UUID) -> Void {
        guard let index = tasks.firstIndex(where: {$0.id == id}) else { print("TASK ID NOT FOUND"); return }
        tasks[index].isSuspended = true
        tasks[index].process.interrupt()
    }
    
    static func runAllTasks(_ linkOutput: Bool? = false) throws -> Void {
        for i in 0...tasks.count - 1 {
            do {
                try tasks[i].process.run()
                if linkOutput! { linkOutputOf(i) }
            } catch {
                print("\(error)")
            }
        }
    }
    
    static func runTask(_ id: UUID, _ linkOutput: Bool? = false, input: String? = nil) throws -> Void {
        for task in tasks where task.id == id {
            
            try task.process.run()
            if input != nil {
                task.inputPipe.fileHandleForWriting.write(input!.data(using: .utf8)!)
            }
            if (linkOutput!) {
                linkOutputOf(id)
            }
        }
    }
    
    static func linkOutputOf(_ index: Int) -> Void {
        let data = try? tasks[index].pipe.fileHandleForReading.readToEnd()
    
        if data == nil {
            tasks[index].output = "Empty output"
        } else {
            tasks[index].output = String(data: data!, encoding: .utf8)!
        }
        guard let output = tasks[index].output else {
            print("Empty output")
            return
        }
        print(output)
    }
    
    static func linkOutputOf(_ id: UUID) -> Void {
        guard let index = tasks.firstIndex(where: { $0.id == id })
        else {
            return
        }
        linkOutputOf(index)
    }
}

