//
//  PeerSession.swift
//  LoginSandbox
//
//  Created by Blair Mitchelmore on 2023-11-16.
//

import Foundation
import MultipeerConnectivity

class PeerSession: NSObject, MCSessionDelegate {
    
    let session: MCSession
    private var listeners: [String:(Event) -> Void] = [:]
    
    init(peerId: MCPeerID) {
        session = MCSession(peer: peerId)
        super.init()
        session.delegate = self
    }
    
    enum Event {
        case data(Data)
        case connected(MCPeerID)
    }
    
    func listen(_ listener: @escaping (Event) -> Void) -> String {
        let id = UUID().uuidString
        listeners[id] = listener
        return id
    }
    
    func stopListening(_ id: String) {
        listeners.removeValue(forKey: id)
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
        log("Peer: \(peerID), Resource: \(resourceName), URL: \(String(describing: localURL)), Error: \(String(describing: error))")
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        log("Peer: \(peerID), State: \(state)")
        if state == .connected {
            for (_, listener) in listeners {
                listener(.connected(peerID))
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        log("Peer: \(peerID), Data: \(data)")
        for (_, listener) in listeners {
            listener(.data(data))
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        log("Peer: \(peerID), Stream: \(streamName)")
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        log("Peer: \(peerID), Certificate: \(String(describing: certificate))")
        certificateHandler(true)
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        log("Peer: \(peerID), Resource: \(resourceName), Progress: \(progress)")
    }
}
