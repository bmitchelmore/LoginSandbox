//
//  main.swift
//  LaunchAgent
//
//  Created by Blair Mitchelmore on 2023-11-14.
//

import Foundation

log("Starting agent")

let handler = XPCHandler()
let listener = NSXPCListener(machServiceName: "ca.burea.labs.login-sandbox.launch-agent")

listener.delegate = handler
listener.activate()

log("Listener activated")

RunLoop.main.run()

log("Stopping agent: \(listener)")
