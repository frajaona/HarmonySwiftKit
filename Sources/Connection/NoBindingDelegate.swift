//
//  NoBindingDelegate.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 08/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation
import XMPPFramework

/**
 XMPPStreamDelegate protocol implementation for stream that does not require binding
 */
class NoBindingDelegate: NSObject, XMPPCustomBinding, XMPPStreamDelegate {
    
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
