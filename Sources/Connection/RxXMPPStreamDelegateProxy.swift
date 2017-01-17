/*
 * Copyright (C) 2017 Fred Rajaona
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
            return result ?? true
        }
        return true
    }
    
}


