//
//  HarmonyHub.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 13/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation
import RxSwift

public class HarmonyHub {

    fileprivate static let id = "21345678-1234-5678-1234-123456789012-1"
    
    public let deviceManager: Observable<DeviceManager>
    
    fileprivate let connector: Connector

    init(ip: String) {
        let stream = RxXMPPStream()!
        connector = DefaultConnector(with: stream, authenticator: DefaultAuthenticator(), ip: ip, username: "guest@x.com", password: "guest")
        self.deviceManager = connector.connect()
            .flatMap { success -> Observable<String> in
                let tokenFinder = DefaultTokenFinder()
                return tokenFinder.tokenRequest(sender: stream)
            }
            .flatMap { token -> Observable<DeviceManager> in
                let deviceManager = DefaultDeviceManager(deviceService: DefaultDeviceService(stream: stream, ip: ip, username: token, id: HarmonyHub.id))
                return Observable.just(deviceManager)
            }
            .shareReplay(1)
    }
    

}
