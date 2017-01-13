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

protocol Response {

    associatedtype ResponseType

    var username: String { get }

    func parse(stringValue: String) -> ResponseType?
}

extension Response {


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

struct GetCurrentActivityResponse: Response {

    let username: String
    var configuration: Configuration

    func parse(stringValue: String) -> Activity? {
        if stringValue.contains("result=") {
            let value = stringValue.replacingOccurrences(of: "result=", with: "")
            if let activities = configuration.activities {
                return activities.first(where: { activity in
                    return activity.id == value
                })
            }
        }
        return nil
    }

}
