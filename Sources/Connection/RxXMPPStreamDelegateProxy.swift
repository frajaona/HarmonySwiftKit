//
//  RxXMPPStreamDelegateProxy.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 30/12/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import RxSwift
import RxCocoa
import XMPPFramework

class RxXMPPStreamDelegateProxy: DelegateProxy, DelegateProxyType, XMPPStreamDelegate {

    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        if let stream = object as? RxXMPPStream {
            return stream.delegate
        }
        return nil
    }

    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        if let stream = object as? RxXMPPStream, let d = delegate as? XMPPStreamDelegate {
            stream.delegate = d
        }
    }

    // Use a PublishSubject to forward xmppStreamWillBind in order to be able to provide a custom binding object
    let willBindSubject = PublishSubject<RxXMPPStream>()

    func xmppStreamWillBind(_ sender: XMPPStream!) -> XMPPCustomBinding! {
        willBindSubject.onNext(sender as! RxXMPPStream)
        if let delegate = self._forwardToDelegate {
            let result = delegate.xmppStreamWillBind?(sender)
            return result ?? nil
        }
        return nil
    }

    // Use a PublishSubject to forward received message events because we won't be able to use a selector for this method.
    // In fact the delegate methods called when receiving XMPPMessage, IQ, presence have the same signature
    // and Swift won't be able to see the difference in any way I tried.

    let receiveXMPPMessageSubject = PublishSubject<(RxXMPPStream, XMPPMessage)>()

    func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
        receiveXMPPMessageSubject.onNext((sender as! RxXMPPStream, message))
        self._forwardToDelegate?.xmppStream?(sender, didReceive: message)
    }


    let receiveIQSubject = PublishSubject<(RxXMPPStream, XMPPIQ)>()

    func xmppStream(_ sender: XMPPStream!, didReceive iq: XMPPIQ!) -> Bool {
        receiveIQSubject.onNext((sender as! RxXMPPStream, iq))
        if let delegate = self._forwardToDelegate {
            let result = delegate.xmppStream?(sender, didReceive: iq)
            return result ?? false
        }
        return false
    }
    
}


