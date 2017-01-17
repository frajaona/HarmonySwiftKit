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
import XMPPFramework

/**
 The Device Manager protocol provides a way to interact with Devices and Activities of an Harmony Hub
 */
public protocol DeviceManager {

    /**
     Device List observable
     */
    var devices: Observable<[Device]> { get }

    /**
     Activity List observable
     */
    var activities: Observable<[Activity]> { get }

    /**
     Current Activity observable
     */
    var currentActivity: Observable<Activity> { get }

    /**
     Observable for sending click
     
     **Click will be performed per subscribed observer.**
     */
    func click(action: Action) -> Observable<Bool>

    /**
     Observable for sending press action

     **Click will be performed per subscribed observer.**
     */
    func press(action: Action) -> Observable<Bool>

    /**
     Observable for sending release action

     **Click will be performed per subscribed observer.**
     */
    func release(action: Action) -> Observable<Bool>
}

/**
 The Device Manager default implementation that use a DeviceService instance to bind to a Harmony Hub
 */
public class DefaultDeviceManager: DeviceManager {

    fileprivate let log = Logger.get()
    fileprivate let service: DeviceService

    /**
     Observable used to retrieve the Harmony Hub configuration
     */
    fileprivate var configuration: Observable<Configuration>

    fileprivate(set) public var devices: Observable<[Device]>
    fileprivate(set) public var activities: Observable<[Activity]>
    fileprivate(set) public var currentActivity: Observable<Activity>

    /**
     Returns an instance of DeviceManager that will use the given DeviceService
     
     - parameter deviceService: The DeviceService instance for binding
     */
    init(deviceService: DeviceService) {
        self.service = deviceService
        self.configuration = service.configuration().shareReplay(1)

        self.devices = configuration.map { config in
            return config.devices
        }

        self.activities = configuration.map { config in
            return config.activities
        }

        self.currentActivity = configuration.flatMap { config in
            return deviceService.currentActivity(for: config)
        }
    }

    public func click(action: Action) -> Observable<Bool> {
        return service.click(for: action)
    }

    public func press(action: Action) -> Observable<Bool> {
        return service.touchDown(for: action)
    }

    public func release(action: Action) -> Observable<Bool> {
        return service.touchUp(for: action)
    }

}
