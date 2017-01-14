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

    func click(for action: Action) -> Observable<Bool>

    func touchDown(for action: Action) -> Observable<Bool>

    func touchUp(for action: Action) -> Observable<Bool>
}

class DefaultDeviceService: DeviceService {


    fileprivate let log = Logger.get()
    fileprivate let stream: RxXMPPStream
    fileprivate let backgroundScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "Device List Parsing")
    fileprivate let ip: String
    fileprivate let username: String
    fileprivate let id: String

    let disposeBag = DisposeBag()
    
    let connection: Observable<ConnectorError>
    
    let connector: Connector

    init(stream: RxXMPPStream, ip: String, username: String, id: String) {
        self.stream = stream
        self.username = username
        self.id = id
        self.ip = ip
        self.connector = DefaultConnector(with: stream, authenticator: DefaultAuthenticator(), ip: ip, username: username + "@x.com", password: username)
        
        connection = connector.connect().shareReplay(1)
    }

    func currentActivity(for configuration: Configuration) -> Observable<Activity> {
        let sender = self.stream
        let command = GetCurrentActivityCommand()
        let response = GetCurrentActivityResponse(username: username, configuration: configuration)
        return connection.flatMap { success in
                return command.executeRequest(sender: sender, username: self.username, id: self.id)
            }
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
        return connection.flatMap { success in
                return command.executeRequest(sender: sender, username: self.username, id: self.id)
            }
            .flatMap { sender in
                return sender.rx_xmppStreamDidReceiveIq()
            }
            .observeOn(backgroundScheduler)
            .flatMap { sender, iq in
                return response.find(in: iq)
            }
            .observeOn(MainScheduler.instance)
    }

    func click(for action: Action) -> Observable<Bool> {
        let command = ClickCommand(action: action)
        return command.executeRequest(sender: stream, username: username, id: id)
            .flatMap { sender in
                return Observable.just(true)
            }
    }

    func touchDown(for action: Action) -> Observable<Bool> {
        let command = ExecuteActionCommand(action: action, pressed: true)
        return command.executeRequest(sender: stream, username: username, id: id)
            .flatMap { sender in
                return Observable.just(true)
        }
    }

    func touchUp(for action: Action) -> Observable<Bool> {
        let command = ExecuteActionCommand(action: action, pressed: false)
        return command.executeRequest(sender: stream, username: username, id: id)
            .flatMap { sender in
                return Observable.just(true)
        }
    }
}
