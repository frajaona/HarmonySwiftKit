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

    func connect() -> Observable<Bool>
}

enum ConnectorError: Error {
    case failedCreatingStream
    case failedStartingConnection
    case failedRequestingAuthentication
    case failedRequestingToken
}

class DefaultConnector: Connector {

    internal func connect() -> Bool {
        return false
    }


    fileprivate let log = Logger.get()

    fileprivate let ip = "192.168.240.156"
    fileprivate static let connectionId = "21345678-1234-5678-1234-123456789012-1"


    fileprivate var binding: ConnectorBinding?

    fileprivate let authenticator: Authenticator

    fileprivate let stream: RxXMPPStream!

    fileprivate let disposeBag = DisposeBag()

    fileprivate let willBindDelegate = WillBindDelegate(with: DefaultConnector.connectionId)
    
    let connected = Variable<Bool>(false)

    var jointAuthRequest: ((RxXMPPStream) throws -> Observable<RxXMPPStream>) {
        return { (sender) -> Observable<(RxXMPPStream)> in
            let logger = Logger.get()
            logger.debug("stream connected, trying authentication...")
            do {
                let authentication = XMPPPlainAuthentication(stream: sender, password: "guest")
                try sender.authenticate(authentication!)
                return sender.rx_xmppStreamDidAuthenticate
            } catch {
                logger.warning("authentication failed: \(error)")
            }
            throw ConnectorError.failedRequestingAuthentication
        }
    }

    var jointTokenRequest: ((RxXMPPStream) throws -> Observable<(RxXMPPStream, XMPPIQ)>) {
        return { (sender) -> Observable<(RxXMPPStream, XMPPIQ)> in
            let logger = Logger.get()
            logger.debug("authentication succeeded")

            if let query = XMLElement(name: "oa", xmlns: "connect.logitech.com") {
                query.addAttribute(withName: "mime", stringValue: "vnd.logitech.connect/vnd.logitech.pair")
                query.stringValue = "method=pair:name=domoticz#iOS10.1.0#iPhone"

                let iq = XMPPIQ(type: "get", child: query)
                iq?.addAttribute(withName: "from", stringValue: "guest")
                iq?.addAttribute(withName: "id", stringValue: DefaultConnector.connectionId)
                logger.debug("requesting authentication token")
                sender.send(iq)
                return sender.rx_xmppStreamDidReceiveIq
            }
            throw ConnectorError.failedRequestingToken
        }
    }


    var jointResult: ((RxXMPPStream, XMPPIQ) -> Observable<Bool>) {
        return { [unowned self] (sender, iq) -> Observable<Bool> in
            return Observable.create { observer in
                let logger = Logger.get()
                logger.debug("stream received iq: \(iq)")
                let result = self.authenticator.handle(iq: iq)
                if  result == .success {
                    self.connected.value = true
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    logger.debug("cannot find token: \(result)")
                }
                return Disposables.create()
            }
        }

    }

    var connectionObservable: Observable<Bool> {
        return stream.rx_xmppStreamDidConnect
            .observeOn(MainScheduler.instance)
            .flatMap(jointAuthRequest)
            .flatMap(jointTokenRequest)
            .flatMap(jointResult)
    }

    init(with stream: RxXMPPStream, authenticator: Authenticator) {
        self.stream = stream
        self.authenticator = authenticator
        stream.rx_delegate.setForwardToDelegate(willBindDelegate, retainDelegate: false)
    }

    func connect() -> Observable<Bool> {
        let log = self.log
        let stream = self.stream!
        return connected.asObservable()
            .flatMapLatest { [unowned self] (connected) -> Observable<Bool> in
                if connected {
                    return Observable<Bool>.just(true)
                } else {
                    log.debug("Connecting " + self.ip)
                    let jid = XMPPJID(string: "guest@x.com")
                    stream.myJID = jid
                    stream.hostName = self.ip
                    
                    return stream.rx_connect
                        .observeOn(MainScheduler.instance)
                        .flatMap { [unowned self] connected -> Observable<Bool> in
                            if connected {
                                return self.connectionObservable
                            }
                            self.connected.value = false
                            return Observable<Bool>.just(false)
                    }
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
