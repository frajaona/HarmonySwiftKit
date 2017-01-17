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

/**
 The DeviceService protocol defines methods to interact with a remote Harmony Hub service
 */
protocol DeviceService {

    /**
     Observable sequence of Configuration for Configuration request.

     Configuration request starts after observer is subscribed and not after invoking this method.

     **Configuration requests will be performed per subscribed observer.**

     This observable only generates error if connection fails. In this case, the sequence is terminated

     - returns: Observable sequence of Configuration.
     */
    func configuration() -> Observable<Configuration>

    /**
     Observable sequence of Activity for current Activity request.

     Request starts after observer is subscribed and not after invoking this method.

     **Requests will be performed per subscribed observer.**

     This observable only generates error if connection fails. In this case, the sequence is terminated

     - parameter configuration: the configuration where to find the Activity
     - returns: Observable sequence of Activity.
     */
    func currentActivity(for configuration: Configuration) -> Observable<Activity>

    /**
     Observable sequence of Bool for sending click command.

     Command starts after observer is subscribed and not after invoking this method.

     **Commands will be performed per subscribed observer.**

     This observable only generates error if connection fails. In this case, the sequence is terminated

     - parameter action: the device's action that will be 'clicked'
     - returns: Observable sequence of Bool.
     */
    func click(for action: Action) -> Observable<Bool>

    /**
     Observable sequence of Bool for sending pressed command.

     Command starts after observer is subscribed and not after invoking this method.

     **Commands will be performed per subscribed observer.**

     This observable only generates error if connection fails. In this case, the sequence is terminated

     - parameter action: the device's action that will be 'pressed'
     - returns: Observable sequence of Bool.
     */
    func touchDown(for action: Action) -> Observable<Bool>

    /**
     Observable sequence of Bool for sending released command.

     Command starts after observer is subscribed and not after invoking this method.

     **Commands will be performed per subscribed observer.**

     This observable only generates error if connection fails. In this case, the sequence is terminated

     - parameter action: the device's action that will be 'released'
     - returns: Observable sequence of Bool.
     */
    func touchUp(for action: Action) -> Observable<Bool>
}

/**
 The DefaultDeviceService class is used to interact with a remote Harmony Hub by using a RxXMPPStream instance
 */
class DefaultDeviceService: DeviceService {


    fileprivate let log = Logger.get()

    /**
     This scheduler is used for parsing Configuration json and Current Activity response on a background thread
     */
    fileprivate let backgroundScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "Parsing Queue")

    /**
     Observable for connection that shares a single subscription
     All Command observables must be chained with this one
     */
    fileprivate let connection: Observable<ConnectorError>

    /**
     The stream used to send commands
     */
    fileprivate let stream: RxXMPPStream

    /**
     The remote ip of the device
     */
    fileprivate let ip: String

    /**
     The username used to connect to the device
     */
    fileprivate let username: String

    /**
     The id used to send commands
     */
    fileprivate let id: String

    /**
     The Connector object used to connect to the device
     */
    fileprivate let connector: Connector
    
    /**
     Create a DeviceService that will interect with a remote Harmony Hub by using the given stream and credentials
     */
    init(stream: RxXMPPStream, ip: String, username: String, id: String) {
        self.stream = stream
        self.username = username
        self.id = id
        self.ip = ip
        self.connector = DefaultConnector(with: stream, authenticator: DefaultAuthenticator(), ip: ip, username: username + "@x.com", password: username)
        
        connection = connector.connect().shareReplay(1)
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

    func click(for action: Action) -> Observable<Bool> {
        let command = ClickCommand(action: action)
        return connection.flatMap { success in
                return command.executeRequest(sender: self.stream, username: self.username, id: self.id)
            }
            .flatMap { sender in
                return Observable.just(true)
            }
    }

    func touchDown(for action: Action) -> Observable<Bool> {
        let command = ExecuteActionCommand(action: action, pressed: true)
        return connection.flatMap { success in
                return command.executeRequest(sender: self.stream, username: self.username, id: self.id)
            }
            .flatMap { sender in
                return Observable.just(true)
        }
    }

    func touchUp(for action: Action) -> Observable<Bool> {
        let command = ExecuteActionCommand(action: action, pressed: false)
        return connection.flatMap { success in
                return command.executeRequest(sender: self.stream, username: self.username, id: self.id)
            }
            .flatMap { sender in
                return Observable.just(true)
        }
    }
}
