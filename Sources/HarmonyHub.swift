/*
 * Copyright (C) 2017 Fred Rajaona
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import RxSwift

/**
 Client that provide a DeviceManager to interact with Devices and Activities of an Harmony Hub
 */
public class HarmonyHub {

    fileprivate static let id = "21345678-1234-5678-1234-123456789012-1"

    /**
     Observable sequence of DeviceManager for DeviceManager instanciation.

     Instatiation starts after observer is subscribed.

     **Instanciation will be performed once for all subscribed observer.**

     This observable only generates error if connection fails. In this case, the sequence is terminated

     - returns: Observable sequence of DeviceManager.
     */
    public let deviceManager: Observable<DeviceManager>

    /**
     Connector used to find the credentials to use with the Device Manager
     */
    fileprivate let userFinderConnector: Connector

    /**
     Instanciate a client that will connect to the given ip address
     
     - parameter ip: The ip address to connect
     */
    init(ip: String) {
        let stream = RxXMPPStream()!
        userFinderConnector = DefaultConnector(with: stream, authenticator: DefaultAuthenticator(), ip: ip, username: "guest@x.com", password: "guest")

        self.deviceManager = userFinderConnector.connect()
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
