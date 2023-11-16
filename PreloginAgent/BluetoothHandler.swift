//
//  BluetoothHandler.swift
//  LaunchAgent
//
//  Created by Blair Mitchelmore on 2023-11-14.
//

import Foundation
import CoreBluetooth

class BluetoothHandler: NSObject, CBPeripheralManagerDelegate {
    private var manager: CBPeripheralManager?
    private let queue = DispatchQueue(label: "ca.burea.labs.login-sandbox.prelogin-agent.bluetooth")
    private var callback: OneshotCallback<CBManagerState, Never>?
    
    func check() async -> CBManagerState {
        log("Starting bluetooth")
        manager = CBPeripheralManager(delegate: self, queue: queue)
        return await withCheckedContinuation { cont in
            callback = OneshotCallback {
                cont.resume(with: $0)
            }
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        log("State: \(peripheral.state)")
        callback?.finish(.success(peripheral.state))
    }
}
