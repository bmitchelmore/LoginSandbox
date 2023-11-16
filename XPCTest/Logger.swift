//
//  Logger.swift
//  LoginSandbox
//
//  Created by Blair Mitchelmore on 2023-11-12.
//

import Foundation

class WritingHandle {
    private let file: FileHandle
    
    deinit {
        try? file.synchronize()
        try? file.close()
    }
    
    init(path: String) throws {
        self.file = try FileHandle(forUpdating: URL(filePath: path))
        try file.seekToEnd()
    }
    
    func write(_ string: String) throws {
        guard let data = string.data(using: .utf8) else {
            return
        }
        try file.write(contentsOf: data)
    }
}

private var first: AtomicBoolean = true
private func file() -> WritingHandle {
    let path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appending(component: "login-sandbox-xpc-test.log")
    if !FileManager.default.fileExists(atPath: path.path()) {
        print("Creating log file at \(path)")
        if FileManager.default.createFile(atPath: path.path(), contents: nil) == false {
            print("Failed to create log file!")
        }
    }
    let file = try! WritingHandle(path: path.path())
    if first.compareAndSwap(true, to: false) {
        print("Starting log file at \(path)")
        try? file.write("\n\n")
    }
    return file
}
private let formatter = ISO8601DateFormatter()
private let queue = DispatchQueue(label: "ca.burea.labs.login-sandbox.launch-agent.logger")

func log(_ message: String, name: String = #fileID, function: String = #function, line: Int = #line) {
    let now = formatter.string(from: .now)
    let string = "[\(now)] \(name):\(function):\(line) \(message)\n"
    queue.sync {
        try? file().write(string)
        print(string)
    }
}
