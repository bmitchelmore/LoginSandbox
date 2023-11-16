//
//  PeerAdvertiser.swift
//  PeerAdvertiser
//
//  Created by Blair Mitchelmore on 2023-11-16.
//

import Foundation
import MultipeerConnectivity

class PeerAdvertiser: NSObject, MCNearbyServiceAdvertiserDelegate, ObservableObject {
    let peerId: MCPeerID
    let advertiser: MCNearbyServiceAdvertiser
    let session: PeerSession
    var listener: String?
    
    deinit {
        if let listener {
            session.stopListening(listener)
        }
    }
    
    override init() {
        peerId = MCPeerID(displayName: "Mobile")
        advertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: "okta-login")
        session = PeerSession(peerId: peerId)
        super.init()
        advertiser.delegate = self
        listener = session.listen { [session] event in
            switch event {
            case .data:
                break
            case .connected(let peerID):
                if let data = "Hello".data(using: .utf8) {
                    try? session.session.send(data, toPeers: [peerID], with: .reliable)
                }
            }
        }
    }
    
    func start() {
        advertiser.startAdvertisingPeer()
    }
    
    func stop() {
        advertiser.stopAdvertisingPeer()
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        log("Peer: \(peerID)")
        log("Context: \(String(describing: context))")
        
        invitationHandler(true, session.session)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        log("Error: \(error)")
    }
}
