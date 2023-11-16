//
//  BluetoothHandler.swift
//  LaunchAgent
//
//  Created by Blair Mitchelmore on 2023-11-14.
//

import Foundation
import CoreBluetooth

class OneshotCallback<T> {
    var complete: AtomicBoolean = false
    let callback: (T) -> Void
    
    init(callback: @escaping (T) -> Void) {
        self.callback = callback
    }
    
    func finish(_ result: T) {
        guard complete.compareAndSwap(false, to: true) else {
            return
        }
        callback(result)
    }
}

class BluetoothHandler: NSObject, CBPeripheralManagerDelegate {
    private var manager: CBPeripheralManager?
    private let queue = DispatchQueue(label: "ca.burea.labs.login-sandbox.launch-agent.bluetooth")
    private var callback: OneshotCallback<CBManagerState>?
    
    func check() async -> CBManagerState {
        log("Starting bluetooth")
        manager = CBPeripheralManager(delegate: self, queue: queue)
        return await withCheckedContinuation { cont in
            callback = OneshotCallback {
                cont.resume(returning: $0)
            }
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        log("State: \(peripheral.state)")
        callback?.finish(peripheral.state)
    }
}
