//
//  Connector.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 24/12/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation
import XMPPFramework
import RxSwift
import RxCocoa

/**
 The connector protocol defines a method to connect to something
 and a variable to track connection status
 */
protocol Connector {

    /**
     RxSwift Variable to track connection status
     */
    var connected: Variable<Bool> { get }

    /**
     Observable sequence of ConnectorError for connection request.

     Connection process starts after observer is subscribed and not after invoking this method.
     If connector is already connected, it just returns ConnectorError.success

     **Connection requests will be performed per subscribed observer.**

     Any error during connection will cause observed sequence to terminate with error.

     - returns: Observable sequence of ConnectorError.
     */
    func connect() -> Observable<ConnectorError>
}

/**
 Connector errors
 */
enum ConnectorError: Error {
    /// Connection succeeded, or already connected
    case success
    /// Connection failed because XMPPStream connect method failed
    case failedStartingConnection
    /// Connection failed because XMPPStream failed to start authentication
    case failedRequestingAuthentication
    case xmppError
}


class DefaultConnector: Connector {

    fileprivate let log = Logger.get()

    fileprivate let stream: RxXMPPStream
    
    fileprivate let authenticator: Authenticator

    fileprivate let disposeBag = DisposeBag()

    fileprivate let ip: String

    fileprivate let username: String

    fileprivate let password: String

    /**
     RxSwift Variable to track connection status
    */
    let connected = Variable<Bool>(false)

    /**
     Create a Connector that will connect the given stream by using the given credentials and Authenticator
     */
    init(with stream: RxXMPPStream, authenticator: Authenticator, ip: String, username: String, password: String) {
        self.stream = stream
        self.authenticator = authenticator
        self.ip = ip
        self.username = username
        self.password = password
        stream.rx_delegate.setForwardToDelegate(NoBindingDelegate(), retainDelegate: true)
    }


    func connect() -> Observable<ConnectorError> {
        if connected.value {
            return Observable.just(.success)
        } else {
            log.debug("Connecting " + ip)
            let jid = XMPPJID(string: username)
            stream.myJID = jid
            stream.hostName = ip

            return stream.rx_connect(with: 10)
                .observeOn(MainScheduler.instance)
                .flatMapFirst { [unowned self] connected -> Observable<ConnectorError> in
                    if connected {
                        return self.stream.rx_xmppStreamDidConnect()
                            .observeOn(MainScheduler.instance)
                            .flatMap { sender in
                                return self.authenticator.authenticationRequest(sender: sender, username: self.username, password: self.password)
                            }
                            .flatMap { sender -> Observable<ConnectorError> in
                                self.connected.value = true
                                return Observable.just(ConnectorError.success)
                            }
                    }
                    self.connected.value = false
                    return Observable.just(.failedStartingConnection)
                }
                .catchError { [unowned self] error in
                    self.log.warning("error while connecting: \(error)")
                    switch error {
                    case _ as AuthenticatorError:
                        return Observable.just(.failedRequestingAuthentication)
                        
                    case let e as ConnectorError:
                        return Observable.just(e)
                        
                    default:
                        return Observable.just(.xmppError)
                    }
                }
        }
    }

}

