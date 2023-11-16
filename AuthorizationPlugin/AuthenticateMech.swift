//
//  AuthenticateMech.swift
//  LoginSandbox
//
//  Created by Blair Mitchelmore on 2023-11-13.
//

import Foundation
import CoreBluetooth

class AuthenticateMech: Mechanism, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager?
    private var queue: DispatchQueue
    private var group: DispatchGroup
    private var xpc: XPCManager
    private var browser: PeerBrowser
    private var session: PeerSession
    
    override init(plugin: AuthPlugin, engine: AuthorizationEngineRef) {
        queue = DispatchQueue(label: "ca.burea.labs.login-sandbox.authenticate-mech.bluetooth")
        group = DispatchGroup()
        xpc = XPCManager()
        browser = PeerBrowser()
        session = PeerSession(peerId: browser.peerId)
        super.init(plugin: plugin, engine: engine)
        peripheralManager = CBPeripheralManager(delegate: self, queue: queue)
        
        log("Enter group")
        group.enter()
        
        log("Enter group")
        group.enter()
        
        log("Enter group")
        group.enter()
        
        group.notify(queue: .main) {
            log("Group notified")
            self.allowLogin()
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        log("State: \(peripheral.state)")
        log("Leave group")
        group.leave()
    }
    
    override func invoke() -> OSStatus {
        log("Mechanism Invoked")
        
        log("Enter group")
        group.enter()
        
        log("Starting local network request")
        URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://burea.ca")!)) { data, response, error in
            log("Data: \(String(describing: data))")
            log("Response: \(String(describing: response))")
            log("Error: \(String(describing: error))")
            log("Leave group")
            self.group.leave()
        }.resume()
        
        log("Starting MultipeerConnectivity search")
        browser.search { [browser, session, group] event in
            switch event {
            case .found(let peerID, _):
                session.connect(peerID, from: browser)
                var listener: String?
                listener = session.listen { event in
                    switch event {
                    case .data(let data):
                        log("Data: \(data)")
                        log("Leave group")
                        group.leave()
                        if let listener = listener {
                            session.stopListening(listener)
                        }
                    case .connected(let peerID):
                        if let data = "Hello".data(using: .utf8) {
                            try? session.session.send(data, toPeers: [peerID], with: .reliable)
                        }
                    }
                }
            case .lost:
                log("Leave group")
                group.leave()
            case .fail:
                log("Leave group")
                group.leave()
            }
        }
        
        Task {
            do {
                log("Attempting XPC Connect")
                log("Enter group")
                group.enter()
                let proxy = try await xpc.connect()
                
                log("Checking for bluetooth via XPC")
                let result = await proxy.checkBluetooth()
                log("Result from XPC: \(result)")
                log("Leave group")
                group.leave()
            } catch {
                log("XPC Connect failed: \(error)")
                log("Leave group")
                group.leave()
            }
        }
        
        log("Leave group")
        group.leave()
        return errSecSuccess
    }
}
