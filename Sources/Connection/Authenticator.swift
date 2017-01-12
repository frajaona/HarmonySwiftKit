//
//  Authenticator.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 08/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation
import RxSwift
import XMPPFramework

/**
 The Authenticator protocol provides a method to create Observable request for authenticating through a RxXMPP Stream
 */
protocol Authenticator {
    
    /**
     Observable sequence of stream for authentication request.
     
     Performing of request starts after observer is subscribed and not after invoking this method.
     
     **Authentication requests will be performed per subscribed observer.**
     
     Any error when sending authentication will cause observed sequence to terminate with error.
     
     - parameter sender: stream used to authenticate.
     - returns: Observable sequence of stream.
     */
    func authenticationRequest(sender: RxXMPPStream, username: String?, password: String) -> Observable<RxXMPPStream>
}

/**
 Authenticator error
 */
enum AuthenticatorError: Error {
    case failedStartingAuthentication
}

/**
 Default authenticator that will use PLAIN authentication method
 */
class DefaultAuthenticator: Authenticator {
    
    fileprivate let log = Logger.get()
    
    func authenticationRequest(sender: RxXMPPStream, username: String?, password: String) -> Observable<RxXMPPStream> {
        let log = self.log
        return Observable<RxXMPPStream>.create { observer in
            log.debug("Trying authentication...")
            do {
                let authentication: XMPPPlainAuthentication?
                if let username = username {
                    authentication = XMPPPlainAuthentication(stream: sender, username: username, password: password)
                } else {
                    authentication = XMPPPlainAuthentication(stream: sender, password: password)
                }
                try sender.authenticate(authentication!)
                observer.onNext(sender)
                observer.onCompleted()
            } catch {
                log.warning("authentication failed: \(error)")
                observer.onError(AuthenticatorError.failedStartingAuthentication)
            }
            return Disposables.create()
        }
        .asObservable()
        .flatMap { sender in
            return sender.rx_xmppStreamDidAuthenticate()
        }
    }
}
