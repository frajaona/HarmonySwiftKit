//
//  Authenticator.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 28/12/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation
import XMPPFramework


/**

 The Authenticator protocol allows to find a session token by parsing IQ message

 */
protocol Authenticator {

    /**
     Handle IQ messages to find an identity token

     - parameter message: the IQ message to process

     - returns: A tuple containing an AuthenticatorError enum that indicates the process status
     and the token if found. **The token is only different from nil if AuthenticatorError is .success**

     */
    func handle(iq message: XMPPIQ) -> (AuthenticatorError, String?)
}

/**
 Authenticator errors
 */
enum AuthenticatorError {
    /// Authentication succeeded, token found
    case success
    /// Found invalid IQ attributes
    case invalidIqAttributes
    /// No <oa> child found in IQ
    case noOaChild
    /// Invalide error code found in <oa> element
    case invalidOaErrorCode
    /// <oa> element has no value
    case noOaValue
    /// <oa> element has an invalid value
    case invalidOaValue
}

class DefaultAuthenticator: Authenticator {

    fileprivate let log = Logger.get()

    func handle(iq message: XMPPIQ) -> (AuthenticatorError, String?) {
        guard let type = message.type(), type == "get", let to = message.attributeStringValue(forName: "to"), to == "guest" else {
            log.debug("receive iq message that has invalid attributes: \(message)")
            return (.invalidIqAttributes, nil)
        }

        guard let child = message.childElement(), let name = child.name, name == "oa" else {
            log.debug("receive iq message that does not contain an oa child: \(message)")
            return (.noOaChild, nil)
        }

        guard let errorCode = child.attributeStringValue(forName: "errorcode"), errorCode == "200" else {
            log.debug("receive iq message containing an oa child with an invalid errorcode: \(child)")
            return (.invalidOaErrorCode, nil)
        }

        guard let value = message.stringValue else {
            log.debug("receive iq message containing an oa that does not have a value: \(child)")
            return (.noOaValue, nil)
        }

        let values = parse(stringValue: value)

        guard let status = values["status"], status == "succeeded", let identity = values["identity"] else {
            log.debug("receive iq message containing an oa that have an invalid value: \(value)")
            return (.invalidOaValue, nil)
        }

        return (.success, identity)
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
