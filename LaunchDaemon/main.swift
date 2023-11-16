//
//  main.swift
//  LaunchDaemon
//
//  Created by Blair Mitchelmore on 2023-11-15.
//

import Foundation

log("Starting daemon")

let handler = XPCHandler()
let listener = NSXPCListener(machServiceName: "ca.burea.labs.login-sandbox.launch-daemon")

listener.delegate = handler
listener.activate()

log("Listener activated")

RunLoop.main.run()

log("Stopping agent: \(listener)")

