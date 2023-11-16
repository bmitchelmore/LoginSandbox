//
//  PeerBrowser.swift
//  LoginSandbox
//
//  Created by Blair Mitchelmore on 2023-11-16.
//

import Foundation
import MultipeerConnectivity

class PeerBrowser: NSObject, MCNearbyServiceBrowserDelegate {
    let peerId: MCPeerID
    let browser: MCNearbyServiceBrowser
    private var handler: ((Event) -> Void)?
    
    override init() {
        peerId = MCPeerID(displayName: "Mac")
        browser = MCNearbyServiceBrowser(peer: peerId, serviceType: "okta-login")
        super.init()
        browser.delegate = self
    }
    
    enum Event {
        case found(MCPeerID, [String:String]?)
        case lost(MCPeerID)
        case fail(Error)
    }
    
    func search(_ handler: @escaping (Event) -> Void) {
        self.handler = handler
        browser.startBrowsingForPeers()
    }
    
    func stop() {
        self.handler = nil
        browser.stopBrowsingForPeers()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        log("Found: \(peerID) \(String(describing: info))")
        handler?(.found(peerID, info))
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        log("Lost peer: \(peerID)")
        handler?(.lost(peerID))
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        log("Error: \(error)")
        handler?(.fail(error))
    }
}
