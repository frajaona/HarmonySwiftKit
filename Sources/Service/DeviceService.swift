//
//  DeviceService.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 11/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation
import RxSwift
import XMPPFramework

protocol DeviceService {

    func configuration() -> Observable<Configuration>

    func currentActivity(for configuration: Configuration) -> Observable<Activity>
}

class DefaultDeviceService: DeviceService {


    fileprivate let log = Logger.get()
    fileprivate let stream: RxXMPPStream
    fileprivate let backgroundScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "Device List Parsing")
    fileprivate let username: String
    fileprivate let id: String

    let disposeBag = DisposeBag()

    init(stream: RxXMPPStream, username: String, id: String) {
        self.stream = stream
        self.username = username
        self.id = id
    }

    func currentActivity(for configuration: Configuration) -> Observable<Activity> {
        let sender = self.stream
        let command = GetCurrentActivityCommand()
        let response = GetCurrentActivityResponse(username: username, configuration: configuration)
        return command.executeRequest(sender: sender, username: username, id: id)
            .flatMap { sender in
                return sender.rx_xmppStreamDidReceiveIq()
            }
            .observeOn(backgroundScheduler)
            .flatMap { sender, iq in
                return response.find(in: iq)
            }
            .observeOn(MainScheduler.instance)
    }

    func configuration() -> Observable<Configuration> {
        let sender = self.stream
        let command = GetConfigurationCommand()
        let response = GetConfigurationResponse(username: username)
        return command.executeRequest(sender: sender, username: username, id: id)
            .flatMap { sender in
                return sender.rx_xmppStreamDidReceiveIq()
            }
            .observeOn(backgroundScheduler)
            .flatMap { sender, iq in
                return response.find(in: iq)
            }
            .observeOn(MainScheduler.instance)
        

    }
}
