//
//  XPCHandler.swift
//  LaunchAgent
//
//  Created by Blair Mitchelmore on 2023-11-14.
//

import Foundation

class XPCHandler: NSObject, NSXPCListenerDelegate {
    deinit {
        log("XPCHandler deinit")
    }
    
    override init() {
        super.init()
        log("xpc handler initialized")
    }
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        log("Received new connection")
        newConnection.exportedInterface = NSXPCInterface(with: XPCInterfaceProtocol.self)
        newConnection.exportedObject = XPCInterface()
        newConnection.activate()
        log("Activated new connection")
        return true
    }
}

@objc(XPCInterfaceProtocol)
protocol XPCInterfaceProtocol {
    func checkBluetooth() async -> Bool
}

class XPCInterface: NSObject, XPCInterfaceProtocol {
    let bluetoothHandler = BluetoothHandler()
    
    func checkBluetooth() async -> Bool {
        log("Checking bluetooth")
        return await bluetoothHandler.check() == .poweredOn
    }
}
