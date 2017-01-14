//
//  DeviceManager.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 09/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation
import RxSwift
import XMPPFramework

public protocol DeviceManager {

    var devices: Observable<[Device]> { get }
    var activities: Observable<[Activity]> { get }
    var currentActivity: Observable<Activity> { get }

    func click(action: Action) -> Observable<Bool>
    func press(action: Action) -> Observable<Bool>
    func release(action: Action) -> Observable<Bool>
}


public class DefaultDeviceManager: DeviceManager {

    fileprivate let log = Logger.get()
    fileprivate let service: DeviceService

    fileprivate let disposeBag = DisposeBag()

    fileprivate var configuration: Observable<Configuration>

    fileprivate(set) public var devices: Observable<[Device]>
    fileprivate(set) public var activities: Observable<[Activity]>

    fileprivate(set) public var currentActivity: Observable<Activity>

    init(deviceService: DeviceService) {
        self.service = deviceService
        self.configuration = service.configuration().shareReplay(1)

        self.devices = configuration.map { config in
            return config.devices ?? [Device]()
        }

        self.activities = configuration.map { config in
            return config.activities ?? [Activity]()
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
