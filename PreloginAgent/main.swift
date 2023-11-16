//
//  main.swift
//  PreloginAgent
//
//  Created by Blair Mitchelmore on 2023-11-15.
//

import Foundation

log("Starting prelogin agent")

let handler = XPCHandler()
let listener = NSXPCListener(machServiceName: "ca.burea.labs.login-sandbox.prelogin-agent")

listener.delegate = handler
listener.activate()

log("Listener activated")

Task {
    let bt = BluetoothHandler()
    let state = await bt.check()
    log("Result from BT: \(state)")
}

RunLoop.main.run()

log("Stopping agent: \(listener)")
