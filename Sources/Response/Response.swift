//
//  Response.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 13/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation
import XMPPFramework
import RxSwift

/**
 The Response protocol defines XMPP IQ responses that are received when sending some XMPP IQ message
 */
protocol Response {

    associatedtype ResponseType

    /**
     The username will be used to check the recipient of the message
     */
    var username: String { get }

    /**
     The main parsing method to handle the XMPP IQ message
     */
    func parse(stringValue: String) -> ResponseType?
}

extension Response {


    /**
     Observable sequence of Response for finding a Response in a XMPP IQ Message.
     
     Finding process starts after observer is subscribed and not after invoking this method.
     
     **Process will be performed per subscribed observer.**
     
     - parameter iq: XMPP IQ message to parse
     - returns: Observable sequence of Response.
     */
    func find(in iq: XMPPIQ) -> Observable<ResponseType> {
        return Observable.create { observer in
            let result: ResponseType? = self.handle(iq: iq, username: self.username)
            if let result = result {
                observer.onNext(result)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    func handle(iq message: XMPPIQ, username: String) -> ResponseType? {
        let log = Logger.get()
        guard message.isGet(), let to = message.recipient, to == username else {
            log.debug("receive iq message that has invalid attributes: \(message)")
            return nil
        }

        guard let value = try? message.getOaValue() else {
            return nil
        }
        return parse(stringValue: value)
    }
}

/**
 The Response containing a configuration (device list, activity list, ...)
 */
struct GetConfigurationResponse: Response {

    let username: String

    func parse(stringValue: String) -> Configuration? {
        guard let jsonValue = try? JSONSerialization.jsonObject(with: stringValue.data(using: String.Encoding.utf8)!) else {
            return nil
        }
        guard let json = jsonValue as? [String: Any] else {
            return nil
        }
        return DefaultConfiguration(json: json)
    }
}

/**
 The Response containing the current activity
 */
struct GetCurrentActivityResponse: Response {

    let username: String
    var configuration: Configuration

    func parse(stringValue: String) -> Activity? {
        if stringValue.contains("result=") {
            let value = stringValue.replacingOccurrences(of: "result=", with: "")
            return configuration.activities.first(where: { activity in
                return activity.id == value
            })
        }
        return nil
    }

}
