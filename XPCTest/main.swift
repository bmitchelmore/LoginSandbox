//
//  main.swift
//  XPCTest
//
//  Created by Blair Mitchelmore on 2023-11-14.
//

import Foundation

print("Hello, World!")

let xpc = XPCManager()

Task {
    do {
        let proxy = try await xpc.connect()
        log("Checking for bluetooth via XPC")
        let result = await proxy.checkBluetooth()
        log("Result from XPC: \(result)")
    } catch {
        log("Error: \(error)")
    }
    exit(0)
}

RunLoop.main.run()
