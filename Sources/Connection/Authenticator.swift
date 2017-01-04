//
//  Authenticator.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 28/12/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation
import XMPPFramework


protocol AuthenticatorDelegate {

    func onFinished(auth: Authenticator)
}

/**

 The Authenticator protocol allows to find a session token by authenticating on the Harmony Hub
 
 The authentication process starts by sending an XMPPIQ stanza to the Harmony Hub.
 The Authenticator will then need to process each received XMPPIQ message to find the session token.

 */
protocol Authenticator {

    var token: String? { get }
    var started: Bool { get }
    func start()
    func handle(iq message: XMPPIQ) -> AuthenticatorError
}

enum AuthenticatorError {
    case success, invalidIqAttributes, noOaChild, invalidOaErrorCode, noOaValue, invalidOaValue
}

class DefaultAuthenticator: Authenticator {

    let log = Logger.get()

    var token: String?
    var started: Bool = false

    /**
     Start authenticator
    */
    func start() {
        started = true
    }


    /**
     Stop authenticator
    */
    func stop() {
        started = false
    }


    /**
     Handle IQ messages to find an identity token
     
     - parameter message: the IQ message to process

     - returns: An AuthenticatorError enum that indicates the process status

    */
    func handle(iq message: XMPPIQ) -> AuthenticatorError {
        guard let type = message.type(), type == "get", let to = message.attributeStringValue(forName: "to"), to == "guest" else {
            log.debug("receive iq message that has invalid attributes: \(message)")
            return .invalidIqAttributes
        }

        guard let child = message.childElement(), let name = child.name, name == "oa" else {
            log.debug("receive iq message that does not contain an oa child: \(message)")
            return .noOaChild
        }

        guard let errorCode = child.attributeStringValue(forName: "errorcode"), errorCode == "200" else {
            log.debug("receive iq message containing an oa child with an invalid errorcode: \(child)")
            return .invalidOaErrorCode
        }

        guard let value = message.stringValue else {
            log.debug("receive iq message containing an oa that does not have a value: \(child)")
            return .noOaValue
        }

        let values = parse(stringValue: value)

        guard let status = values["status"], status == "succeeded", let identity = values["identity"] else {
            log.debug("receive iq message containing an oa that have an invalid value: \(value)")
            return .invalidOaValue
        }

        token = identity

        return .success
    }


    /**
     Parse the given String and returns a dictionary from it
     
     The given String must be formatted like this:

     ````
     key1=value1:key2=value2:key3=value3
     ````

     It returns an empty dictionary if no couple can be found
     
     - parameter value: The String to parse

    */
    func parse(stringValue value: String) -> [String: String] {
        return value.components(separatedBy: ":")
            .map { strValue -> [String] in
                if let index = strValue.characters.index(of: "=") {
                    var nextIndex = index
                    strValue.characters.formIndex(after: &nextIndex)
                    return [strValue.substring(to: index), strValue.substring(from: nextIndex)]
                } else {
                    return strValue.components(separatedBy: "=")
                }
            }
            .reduce([String: String]()) { dict, nextCouple in
                var newDict = dict
                if nextCouple.count == 2, nextCouple[0] != "" {
                    newDict[nextCouple[0]] = nextCouple[1]
                }
                return newDict
        }
    }

}
