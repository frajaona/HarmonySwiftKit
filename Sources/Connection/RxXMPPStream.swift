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

/**
 Reactive version of the XMPPStream class
 */
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

    var rx_delegate: DelegateProxy {
        return RxXMPPStreamDelegateProxy.proxyForObject(self)
    }

    /**
     Observable sequence of boolean for stream connection with connect(withTimeout:) method.
     
     Performing of connection starts after observer is subscribed and not after invoking this method.
     
     **connection will be performed per subscribed observer.**
     
     Any error when calling connect(withTimeout:) will cause observed sequence to terminate with error.
     
     - parameter timeout: URL of `NSURLRequest` request.
     - returns: Observable sequence of boolean indicating if the stream is connected.
     */
    func rx_connect(with timeout: TimeInterval) -> Observable<Bool> {
        return Observable.create { observer in
            do {
                try self.connect(withTimeout: timeout)
                observer.onNext(true)
                observer.onCompleted()
            } catch {
                observer.onError(error)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    func rx_xmppStreamWillConnect() -> Observable<RxXMPPStream> {
        return rx_delegate.methodInvoked(#selector(XMPPStreamDelegate.xmppStreamWillConnect(_:)))
            .map { parameters in
                return try castOrThrow(RxXMPPStream.self, parameters[0])
        }
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    func rx_xmppStreamDidConnect() -> Observable<RxXMPPStream> {
        return rx_delegate.methodInvoked(#selector(XMPPStreamDelegate.xmppStreamDidConnect(_:)))
            .map { parameters in
                return try castOrThrow(RxXMPPStream.self, parameters[0])
        }
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    func rx_xmppStreamConnectDidTimeout() -> Observable<RxXMPPStream> {
        return rx_delegate.methodInvoked(#selector(XMPPStreamDelegate.xmppStreamConnectDidTimeout(_:)))
            .map { parameters in
                return try castOrThrow(RxXMPPStream.self, parameters[0])
        }
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    func rx_xmppStreamDidReceiveXMPPMessage() -> Observable<(RxXMPPStream, XMPPMessage)> {
        let proxy = RxXMPPStreamDelegateProxy.proxyForObject(self)
        return proxy.receiveXMPPMessageSubject
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    func rx_xmppStreamDidReceiveIq() -> Observable<(RxXMPPStream, XMPPIQ)> {
        let proxy = RxXMPPStreamDelegateProxy.proxyForObject(self)
        return proxy.receiveIQSubject
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    func rx_xmppStreamConnectWillBind() -> Observable<RxXMPPStream> {
        let proxy = RxXMPPStreamDelegateProxy.proxyForObject(self)
        return proxy.willBindSubject
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    func rx_xmppStreamDidAuthenticate() -> Observable<RxXMPPStream> {
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
