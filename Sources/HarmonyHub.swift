//
//  HarmonyHub.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 13/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation
import RxSwift

class HarmonyHub {

    static let ip = "192.168.240.156"
    static let id = "21345678-1234-5678-1234-123456789012-1"
    
    let deviceManager: Observable<DeviceManager>

    init() {
        let stream = RxXMPPStream()!
        
        let guestConnector = DefaultConnector(with: stream, authenticator: DefaultAuthenticator(), ip: HarmonyHub.ip, username: "guest@x.com", password: "guest")
        let tokenFinder = DefaultTokenFinder()
        
        deviceManager = guestConnector.connect()
            .flatMap { success -> Observable<String> in
                return tokenFinder.tokenRequest(sender: stream)
            }
            .flatMap { token -> Observable<DeviceManager> in
                let deviceManager = DefaultDeviceManager(deviceService: DefaultDeviceService(stream: stream, ip: HarmonyHub.ip, username: token, id: HarmonyHub.id))
                return Observable.just(deviceManager)
            }
            .shareReplay(1)
    }
    

}
