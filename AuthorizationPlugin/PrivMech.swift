//
//  PrivMech.swift
//  LoginSandbox
//
//  Created by Blair Mitchelmore on 2023-11-12.
//

import Foundation
import CoreBluetooth

class PrivMech: Mechanism, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager?
    private var queue: DispatchQueue
    private var group: DispatchGroup
    
    override init(plugin: AuthPlugin, engine: AuthorizationEngineRef) {
        queue = DispatchQueue(label: "ca.burea.labs.login-sandbox.priv-mech.bluetooth")
        group = DispatchGroup()
        super.init(plugin: plugin, engine: engine)
        peripheralManager = CBPeripheralManager(delegate: self, queue: queue)
        
        group.enter()
        group.enter()
        group.enter()
        
        URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://burea.ca")!)) { data, response, error in
            log("Data: \(String(describing: data))")
            log("Response: \(String(describing: response))")
            log("Error: \(String(describing: error))")
            self.group.leave()
        }.resume()
        
        group.notify(queue: .main) {
            self.allowLogin()
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        log("State: \(peripheral.state)")
        group.leave()
    }
    
    override func invoke() -> OSStatus {
        log("Mechanism Invoked")
        group.leave()
        return errSecSuccess
    }
}
