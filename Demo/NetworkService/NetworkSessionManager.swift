//
//  NetworkReachability.swift
//  ThatsGams
//
//  Created by Admin on 18/12/19.
//  Copyright © 2019 App Studio. All rights reserved.
//

import Foundation
import Reachability

class NetworkSessionManager {
    static let shared = NetworkSessionManager()
    
    private var reachability:Reachability!
    
    var isWiFiReachable: Bool = false
    var isServerReachable: Bool = false
    
    private init() {
        
    }

    func observeReachability() {
        do {
            self.reachability =  try Reachability()
        } catch {
            print( "ERROR: Could not start reachability notifier." )
        }
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            try self.reachability.startNotifier()
        }
        catch(let error) {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }

    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            isServerReachable = true
            isWiFiReachable = false
            print("Network available via Cellular Data.")
            break
        case .wifi:
            isServerReachable = true
            isWiFiReachable = true
            print("Network available via WiFi.")
            break
        case .none:
            isWiFiReachable = false
            isServerReachable = false
            print("Network is not available.")
            break
        case .unavailable:
            isWiFiReachable = false
            isServerReachable = false
            print("Network is not available.")
        }
      }
}
