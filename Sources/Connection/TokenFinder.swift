//
//  TokenFinder.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 28/12/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation
import XMPPFramework
import RxSwift

/**

 The TokenFinder protocol allows to find a session token

 */
protocol TokenFinder {

    
    /**
     Observable sequence of String for token request.
     
     Performing of request starts after observer is subscribed and not after invoking this method.
     
     **Token requests will be performed per subscribed observer.**
     
     This observable won't generate any error
     
     - parameter sender: stream used to obtain a token.
     - parameter connectionId: id used to retrieve the token
     - returns: Observable sequence of String.
     */
    func tokenRequest(sender: RxXMPPStream, connectionId: String) -> Observable<String>
    
}

/**
 TokenFinder errors
 */
enum TokenFinderError: Error {
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
    /// Generic error
    case unknownError
}

class DefaultTokenFinder: TokenFinder {

    static fileprivate let testConnectionId = "21345678-1234-5678-1234-123456789012-1"

    fileprivate let log = Logger.get()

    
    func tokenRequest(sender: RxXMPPStream, connectionId: String = DefaultTokenFinder.testConnectionId) -> Observable<String> {
        let log = self.log
        return Observable<RxXMPPStream>.create { observer in
            log.debug("authentication succeeded")
            
            let query = XMLElement(name: "oa", xmlns: "connect.logitech.com")!
            query.addAttribute(withName: "mime", stringValue: "vnd.logitech.connect/vnd.logitech.pair")
            query.stringValue = "method=pair:name=domoticz#iOS10.1.0#iPhone"
            
            let iq = XMPPIQ(type: "get", child: query)!
            iq.addAttribute(withName: "from", stringValue: "guest")
            iq.addAttribute(withName: "id", stringValue: connectionId)
            log.debug("requesting authentication token")
            sender.send(iq)
            observer.onNext(sender)
            observer.onCompleted()
            return Disposables.create()
        }
        .asObservable()
        .flatMap { sender in
            return sender.rx_xmppStreamDidReceiveIq()
        }
        .flatMap { sender, iq in
            return self.findToken(in: iq, sentBy: sender)
        }
        .flatMap { error, token in
            return Observable.just(token)
        }
    }

    /**
     Observable sequence of (ConnectorError, String?) for parsing iq to find token.
     
     Parsing starts after observer is subscribed and not after invoking this method.
     
     **Parsing will be performed per subscribed observer.**
     
     This observable won't generate any error. It only generates .success when token is found
     
     - parameter iq: iq message to parse
     - parameter sender: stream used to obtain a token.
     - returns: Observable sequence of (ConnectorError, String).
     */
    func findToken(in iq: XMPPIQ, sentBy sender: RxXMPPStream) -> Observable<(ConnectorError, String)> {
        return Observable<(ConnectorError, String)>.create { observer in
            let logger = Logger.get()
            logger.debug("stream received iq: \(iq)")
            let (result, token) = self.handle(iq: iq)
            if  result == .success {
                observer.onNext((.success, token!))
                observer.onCompleted()
            } else {
                logger.debug("cannot find token: \(result)")
            }
            return Disposables.create()
        }
    }
    
    /**
     Handle IQ messages to find an identity token
     
     - parameter message: the IQ message to process
     
     - returns: A tuple containing an TokenFinderError enum that indicates the process status
     and the token if found. **The token is only different from nil if TokenFinderError is .success**
     
     */
    func handle(iq message: XMPPIQ) -> (TokenFinderError, String?) {
        guard message.isGet(), let to = message.recipient, to == "guest" else {
            log.debug("receive iq message that has invalid attributes: \(message)")
            return (.invalidIqAttributes, nil)
        }

        do {
            let value = try message.getOaValue()
            let values = parse(stringValue: value)
            guard let status = values["status"], status == "succeeded", let identity = values["identity"] else {
                log.debug("receive iq message containing an oa that have an invalid value: \(value)")
                return (.invalidOaValue, nil)
            }

            return (.success, identity)

        } catch {
            switch error {
            case XMPPIQError.noOaChild:
                return (.noOaChild, nil)

            case XMPPIQError.invalidOaErrorCode:
                return (.invalidOaErrorCode, nil)

            case XMPPIQError.noOaValue:
                return (.noOaValue, nil)

            default:
                return (.unknownError, nil)
            }
        }
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
