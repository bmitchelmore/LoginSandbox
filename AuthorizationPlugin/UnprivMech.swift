//
//  UnprivMech.swift
//  LoginSandbox
//
//  Created by Blair Mitchelmore on 2023-11-12.
//

import Foundation
import CoreBluetooth
import MultipeerConnectivity

class UnprivMech: Mechanism, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager?
    private var queue: DispatchQueue
    private var group: DispatchGroup
    private let browser: PeerBrowser
    private let session: PeerSession
    
    override init(plugin: AuthPlugin, engine: AuthorizationEngineRef) {
        queue = DispatchQueue(label: "ca.burea.labs.login-sandbox.unpriv-mech.bluetooth")
        group = DispatchGroup()
        browser = PeerBrowser()
        session = PeerSession(peerId: browser.peerId)
        super.init(plugin: plugin, engine: engine)
        peripheralManager = CBPeripheralManager(delegate: self, queue: queue)
        
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        
        URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://burea.ca")!)) { data, response, error in
            log("Data: \(String(describing: data))")
            log("Response: \(String(describing: response))")
            log("Error: \(String(describing: error))")
            self.group.leave()
        }.resume()
        
        browser.search { [browser, session, group] event in
            switch event {
            case .found(let peerID, _):
                session.connect(peerID, from: browser)
                var listener: String?
                listener = session.listen { event in
                    switch event {
                    case .data(let data):
                        log("Data: \(data)")
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
                group.leave()
            case .fail:
                group.leave()
            }
        }
        
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
