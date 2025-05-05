//
//  PeerConnectionManager.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 4/22/25.
//

import MultipeerConnectivity
import Foundation

class PeerConnectionManager : NSObject {
    
    static let shared = PeerConnectionManager()
    
    // MARK: - Configuration
    
    private let serviceType = "assistiveapp"
    
    var isStaffMode: Bool = false {
        didSet {
            resetConnection()
            start()
        }
    }
    
    // MARK: - CORE MPC COMPONENETS
    private var peerID: MCPeerID!
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    
    // MARK: - EVENTS
    var onPeerConnected: ((MCPeerID) -> Void)?
    var onPeerDisconnected: ((MCPeerID) -> Void)?
    
    // MARK: - init
    private override init() {
        super.init()
    }
    
    // MARK: - start Logic
    func start(){
        let name = UIDevice.current.name + (isStaffMode ? "-Staff" : "-User")
        peerID = MCPeerID(displayName: name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        
        if isStaffMode {
            advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo:  nil, serviceType: serviceType)
            advertiser?.delegate = self
            advertiser?.startAdvertisingPeer()
        } else {
            browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
            browser?.delegate = self
            browser?.startBrowsingForPeers()
        }
    }
    
    func stop(){
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session?.disconnect()
    }
    private func resetConnection(){
        stop()
        advertiser = nil
        browser = nil
        session = nil
        peerID = nil
    }
    
    //MARK: Send Paylod
    func send(payload: Payload){
        guard let session = session, !session.connectedPeers.isEmpty else {
            print("No connected peers to send payload")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(payload)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            print ("Payload sent")
        }catch {
            print ("Error sending payload: \(error)")
        }
    }
    var hasConnectedPeers: Bool {
        return session?.connectedPeers.isEmpty == false
    }
}


// MARK: - MCSessionDelegate Compliance
extension PeerConnectionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected to peer: \(peerID.displayName)")
            onPeerConnected?(peerID)
        case .notConnected:
            print("Disconnected from peer: \(peerID.displayName)")
            onPeerDisconnected?(peerID)
        case .connecting:
            print("Connecting to peer: \(peerID.displayName)")
        @unknown default:
            print("Unknown session state for peer: \(peerID.displayName)")
        }
    }
    
    // MARK: Payload Receiving
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID){
        print("Received data from \(peerID.displayName)")
        do{
            let payload = try JSONDecoder().decode(Payload.self, from: data)
            PayloadRouter.shared.handle(payload:payload)
            print("Handled payload of type: \(payload.type)")
        }
        catch {
            print ("failed to decode incoming payload: \(error)")
        }
    }
    
    //MARK: -- Unused but required.
    func session (_ session: MCSession,
                  didReceive stream: InputStream,
                  withName streamName:String,
                  fromPeer peerID: MCPeerID){
    }
    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {
        // Not used in this app. Required for protocol conformance.
        print("Started receiving unused resource '\(resourceName)' from \(peerID.displayName)")
    }

    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: (any Error)?) {
        // Not used in this app. Required for protocol conformance.
        if let error = error {
            print("Error receiving unused resource '\(resourceName)': \(error.localizedDescription)")
        } else {
            print("Finished receiving unused resource '\(resourceName)' from \(peerID.displayName)")
        }
    }
}
// MARK: - MCNearbyServiceAdvertiserDelegate
extension PeerConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from user: \(peerID.displayName)")
        invitationHandler(true, session)
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didNotStartAdvertisingPeer error: any Error) {
        print("Failed to start advertising: \(error.localizedDescription)")
    }
}
// MARK: - MCNearbyServiceBrowserDelegate
extension PeerConnectionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        print("Found staff device: \(peerID.displayName)")
        if let session = session {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        }
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID) {
        print("Lost staff peer: \(peerID.displayName)")
    }
    func browser(_ browser: MCNearbyServiceBrowser,
                 didNotStartBrowsingForPeers error: any Error) {
        print("Failed to start browsing: \(error.localizedDescription)")
    }
    
    
}


