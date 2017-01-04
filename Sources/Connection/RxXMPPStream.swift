//
//  RxXMPPStream.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 30/12/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import XMPPFramework
import RxCocoa
import RxSwift

class RxXMPPStream: XMPPStream {

    var delegate: XMPPStreamDelegate? {
        willSet {
            if let d = delegate {
                removeDelegate(d)
            }
        }
        didSet {
            if let d = delegate {
                addDelegate(d, delegateQueue: DispatchQueue.main)
            }
        }
    }
    
}

extension RxXMPPStream {

    var rx_delegate: DelegateProxy {
        return RxXMPPStreamDelegateProxy.proxyForObject(self)
    }

    var rx_connect: Observable<Bool> {
        return Observable.create { observer in
            do {
                try self.connect(withTimeout: 10)
                observer.onNext(true)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }

    var rx_xmppStreamWillConnect: Observable<RxXMPPStream> {
        return rx_delegate.methodInvoked(#selector(XMPPStreamDelegate.xmppStreamWillConnect(_:)))
            .map { parameters in
                return try castOrThrow(RxXMPPStream.self, parameters[0])
            }
    }

    var rx_xmppStreamDidConnect: Observable<RxXMPPStream> {
        return rx_delegate.methodInvoked(#selector(XMPPStreamDelegate.xmppStreamDidConnect(_:)))
            .map { parameters in
                return try castOrThrow(RxXMPPStream.self, parameters[0])
            }
    }

    var rx_xmppStreamConnectDidTimeout: Observable<RxXMPPStream> {
        return rx_delegate.methodInvoked(#selector(XMPPStreamDelegate.xmppStreamConnectDidTimeout(_:)))
            .map { parameters in
                return try castOrThrow(RxXMPPStream.self, parameters[0])
            }
    }

    var rx_xmppStreamDidReceiveXMPPMessage: Observable<(RxXMPPStream, XMPPMessage)> {
        let proxy = RxXMPPStreamDelegateProxy.proxyForObject(self)
        return proxy.receiveXMPPMessageSubject
    }

    var rx_xmppStreamDidReceiveIq: Observable<(RxXMPPStream, XMPPIQ)> {
        let proxy = RxXMPPStreamDelegateProxy.proxyForObject(self)
        return proxy.receiveIQSubject
    }

    var rx_xmppStreamConnectWillBind: Observable<RxXMPPStream> {
        let proxy = RxXMPPStreamDelegateProxy.proxyForObject(self)
        return proxy.willBindSubject
    }

    var rx_xmppStreamDidAuthenticate: Observable<RxXMPPStream> {
        return rx_delegate.methodInvoked(#selector(XMPPStreamDelegate.xmppStreamDidAuthenticate(_:)))
            .map { parameters in
                return try castOrThrow(RxXMPPStream.self, parameters[0])
        }
    }
}


fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}
