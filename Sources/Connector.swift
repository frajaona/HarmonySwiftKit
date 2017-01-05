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
}

class DefaultConnector: Connector {

    fileprivate let log = Logger.get()

    fileprivate let ip = "192.168.240.156"
    fileprivate static let connectionId = "21345678-1234-5678-1234-123456789012-1"

    fileprivate let authenticator: Authenticator

    fileprivate let stream: RxXMPPStream

    fileprivate let disposeBag = DisposeBag()

    /**
     RxSwift Variable to track connection status
    */
    let connected = Variable<Bool>(false)

    /**
     RxSwift Variable to track authentication token
     */
    let token = Variable<String?>(nil)

    /**
     Create a Connector that will connect the given stream using the given authenticator
     */
    init(with stream: RxXMPPStream, authenticator: Authenticator) {
        self.stream = stream
        self.authenticator = authenticator
        stream.rx_delegate.setForwardToDelegate(NoBindingNeededDelegate(), retainDelegate: true)
    }

    /**
     Observable sequence of ConnectorError for connection request.

     Connection process starts after observer is subscribed and not after invoking this method.
     If connector is already connected, it just returns ConnectorError.success

     **Connection requests will be performed per subscribed observer.**

     Any error during connection will cause observed sequence to terminate with error.

     - returns: Observable sequence of ConnectorError.
     */
    func connect() -> Observable<ConnectorError> {
        if connected.value {
            return Observable.just(.success)
        } else {
            log.debug("Connecting " + self.ip)
            let jid = XMPPJID(string: "guest@x.com")
            stream.myJID = jid
            stream.hostName = self.ip

            return stream.rx_connect(with: 10)
                .observeOn(MainScheduler.instance)
                .flatMapFirst { [unowned self] connected -> Observable<ConnectorError> in
                    if connected {
                        return self.stream.rx_xmppStreamDidConnect()
                            .observeOn(MainScheduler.instance)
                            .flatMap { sender in
                                return self.authenticationRequest(sender: sender)
                            }
                            .flatMap { sender in
                                return sender.rx_xmppStreamDidAuthenticate()
                            }
                            .flatMap { sender in
                                return self.tokenRequest(sender: sender)
                            }
                            .flatMap { sender in
                                return sender.rx_xmppStreamDidReceiveIq()
                            }
                            .flatMap { sender, iq in
                                return self.findToken(in: iq, sentBy: sender)
                            }
                            .flatMap { (error, token) -> Observable<ConnectorError> in
                                self.token.value = token
                                return Observable.just(error)
                            }
                    }
                    self.connected.value = false
                    return Observable.just(.failedStartingConnection)
                }
                .catchError { [unowned self] error in
                    self.log.warning("error while connecting: \(error)")
                    return Observable.just(error as! ConnectorError)
                }
        }
    }


    /**
     Observable sequence of stream for authentication request.

     Performing of request starts after observer is subscribed and not after invoking this method.

     **Authentication requests will be performed per subscribed observer.**

     Any error when sending authentication will cause observed sequence to terminate with error.

     - parameter sender: stream used to authenticate.
     - returns: Observable sequence of stream.
     */
    fileprivate func authenticationRequest(sender: RxXMPPStream) -> Observable<RxXMPPStream> {
        let log = self.log
        return Observable.create { observer in
            log.debug("stream connected, trying authentication...")
            do {
                let authentication = XMPPPlainAuthentication(stream: sender, password: "guest")
                try sender.authenticate(authentication!)
                observer.onNext(sender)
                observer.onCompleted()
            } catch {
                log.warning("authentication failed: \(error)")
                observer.onError(ConnectorError.failedRequestingAuthentication)
            }
            return Disposables.create()
        }
    }


    /**
     Observable sequence of stream for token request.

     Performing of request starts after observer is subscribed and not after invoking this method.

     **Token requests will be performed per subscribed observer.**

     This observable won't generate any error

     - parameter sender: stream used to obtain a token.
     - returns: Observable sequence of stream.
     */
    fileprivate func tokenRequest(sender: RxXMPPStream) -> Observable<RxXMPPStream> {
        let log = self.log
        return Observable.create { observer in
            log.debug("authentication succeeded")

            let query = XMLElement(name: "oa", xmlns: "connect.logitech.com")!
            query.addAttribute(withName: "mime", stringValue: "vnd.logitech.connect/vnd.logitech.pair")
            query.stringValue = "method=pair:name=domoticz#iOS10.1.0#iPhone"

            let iq = XMPPIQ(type: "get", child: query)!
            iq.addAttribute(withName: "from", stringValue: "guest")
            iq.addAttribute(withName: "id", stringValue: DefaultConnector.connectionId)
            log.debug("requesting authentication token")
            sender.send(iq)
            observer.onNext(sender)
            observer.onCompleted()
            return Disposables.create()
        }
    }

    /**
     Observable sequence of (ConnectorError, String?) for parsing iq to find token.

     Parsing starts after observer is subscribed and not after invoking this method.

     **Parsing will be performed per subscribed observer.**

     This observable won't generate any error. It only generates .success when token is found

     - parameter iq: iq message to parse
     - parameter sender: stream used to obtain a token.
     - returns: Observable sequence of (ConnectorError, String).
     */
    fileprivate func findToken(in iq: XMPPIQ, sentBy sender: RxXMPPStream) -> Observable<(ConnectorError, String)> {
        return Observable.create { observer in
            let logger = Logger.get()
            logger.debug("stream received iq: \(iq)")
            let (result, token) = self.authenticator.handle(iq: iq)
            if  result == .success {
                self.connected.value = true
                observer.onNext((.success, token!))
                observer.onCompleted()
            } else {
                logger.debug("cannot find token: \(result)")
            }
            return Disposables.create()
        }
    }
    
    
    /**
     XMPPStreamDelegate protocol implementation for stream that does not require binding
     */
    fileprivate class NoBindingNeededDelegate: NSObject, XMPPCustomBinding, XMPPStreamDelegate {
        
        func start(_ errPtr: NSErrorPointer) -> XMPPBindResult {
            // No binding required
            return XMPPBindResult.BIND_SUCCESS
        }
        
        func handleBind(_ auth: XMLElement!, withError errPtr: NSErrorPointer) -> XMPPBindResult {
            // No binding required
            return XMPPBindResult.BIND_SUCCESS
        }
        
        func xmppStreamWillBind(_ sender: XMPPStream!) -> XMPPCustomBinding! {
            return self
        }
    }

}

