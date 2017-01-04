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

protocol Connector {

    var connected: Variable<Bool> { get }

    func connect() -> Observable<ConnectorError>
}

enum ConnectorError: Error {
    case success
    case failedStartingConnection
    case failedRequestingAuthentication
}

class DefaultConnector: Connector {

    fileprivate let log = Logger.get()

    fileprivate let ip = "192.168.240.156"
    fileprivate static let connectionId = "21345678-1234-5678-1234-123456789012-1"


    fileprivate var binding: ConnectorBinding?

    fileprivate let authenticator: Authenticator

    fileprivate let stream: RxXMPPStream!

    fileprivate let disposeBag = DisposeBag()

    fileprivate let willBindDelegate = WillBindDelegate(with: DefaultConnector.connectionId)
    
    let connected = Variable<Bool>(false)

    func authenticationRequest(sender: RxXMPPStream) throws -> Observable<RxXMPPStream> {
        log.debug("stream connected, trying authentication...")
        do {
            let authentication = XMPPPlainAuthentication(stream: sender, password: "guest")
            try sender.authenticate(authentication!)
            return sender.rx_xmppStreamDidAuthenticate()
        } catch {
            log.warning("authentication failed: \(error)")
            throw ConnectorError.failedRequestingAuthentication
        }
    }

    func tokenRequest(sender: RxXMPPStream) throws -> Observable<(RxXMPPStream, XMPPIQ)> {
        log.debug("authentication succeeded")

        let query = XMLElement(name: "oa", xmlns: "connect.logitech.com")!
        query.addAttribute(withName: "mime", stringValue: "vnd.logitech.connect/vnd.logitech.pair")
        query.stringValue = "method=pair:name=domoticz#iOS10.1.0#iPhone"

        let iq = XMPPIQ(type: "get", child: query)
        iq?.addAttribute(withName: "from", stringValue: "guest")
        iq?.addAttribute(withName: "id", stringValue: DefaultConnector.connectionId)
        log.debug("requesting authentication token")
        sender.send(iq)
        return sender.rx_xmppStreamDidReceiveIq()

    }


    func resultRequest(sender: RxXMPPStream, iq: XMPPIQ) -> Observable<ConnectorError> {
        return Observable.create { observer in
            let logger = Logger.get()
            logger.debug("stream received iq: \(iq)")
            let result = self.authenticator.handle(iq: iq)
            if  result == .success {
                self.connected.value = true
                observer.onNext(.success)
                observer.onCompleted()
            } else {
                logger.debug("cannot find token: \(result)")
            }
            return Disposables.create()
        }
    }

    var connectionObservable: Observable<ConnectorError> {
        return stream.rx_xmppStreamDidConnect()
            .observeOn(MainScheduler.instance)
            .flatMap(authenticationRequest)
            .flatMap(tokenRequest)
            .flatMap(resultRequest)
    }

    init(with stream: RxXMPPStream, authenticator: Authenticator) {
        self.stream = stream
        self.authenticator = authenticator
        stream.rx_delegate.setForwardToDelegate(willBindDelegate, retainDelegate: false)
    }

    func connect() -> Observable<ConnectorError> {
        let log = self.log
        let stream = self.stream!
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
                        return self.connectionObservable
                    }
                    self.connected.value = false
                    return Observable.just(.failedStartingConnection)
                }
                .catchError { error in
                    log.warning("error while connecting: \(error)")
                    return Observable.just(error as! ConnectorError)
                }
        }
    }

}

class WillBindDelegate: NSObject, XMPPStreamDelegate {

    fileprivate let id: String

    init(with connectionId: String) {
        self.id = connectionId
    }

    func xmppStreamWillBind(_ sender: XMPPStream!) -> XMPPCustomBinding! {
        return ConnectorBinding(with: sender, connectionId: id)
    }
}


class ConnectorBinding: NSObject, XMPPCustomBinding {

    private let log = Logger.get()
    private let sender: XMPPStream
    private let id: String
    fileprivate var authenticationToken: String?

    init(with stream: XMPPStream, connectionId: String) {
        sender = stream
        id = connectionId
    }

    func start(_ errPtr: NSErrorPointer) -> XMPPBindResult {
        // No binding required
        return XMPPBindResult.BIND_SUCCESS
    }

    func handleBind(_ auth: XMLElement!, withError errPtr: NSErrorPointer) -> XMPPBindResult {
        // No binding required
        return XMPPBindResult.BIND_SUCCESS
    }

}
