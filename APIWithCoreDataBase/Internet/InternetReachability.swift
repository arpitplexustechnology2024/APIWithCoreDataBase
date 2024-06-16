//
//  InternetReachability.swift
//  APIWithCoreDataBase
//
//  Created by Arpit iOS Dev. on 15/06/24.
//

import Foundation
import Alamofire

class Reachability {
    static let shared = Reachability()
    private let networkReachabilityManager = NetworkReachabilityManager()

    private init() {}

    func isConnectedToNetwork() -> Bool {
        return networkReachabilityManager?.isReachable ?? false
    }

    func startMonitoring() {
        networkReachabilityManager?.startListening { status in
            print("Network Status Changed: \(status)")
        }
    }

    func stopMonitoring() {
        networkReachabilityManager?.stopListening()
    }
}
