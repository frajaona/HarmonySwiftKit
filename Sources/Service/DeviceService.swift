//
//  DeviceService.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 11/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation
import RxSwift
import XMPPFramework

protocol DeviceService {

    func configuration() -> Observable<Configuration>
}

class DefaultDeviceService: DeviceService {

    fileprivate let xmlns = "connect.logitech.com"
    fileprivate let configRequestMime = "vnd.logitech.harmony/vnd.logitech.harmony.engine?config"

    fileprivate let log = Logger.get()
    fileprivate let stream: RxXMPPStream
    fileprivate let backgroundScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "Device List Parsing")
    fileprivate let username: String
    fileprivate let id: String

    let disposeBag = DisposeBag()

    init(stream: RxXMPPStream, username: String, id: String) {
        self.stream = stream
        self.username = username
        self.id = id
    }

    func configuration() -> Observable<Configuration> {
        let log = self.log
        let sender = self.stream
        return Observable<RxXMPPStream>.create { observer in
                log.debug("Requesting configuration")
                let query = XMLElement(name: "oa", xmlns: self.xmlns)!
                query.addAttribute(withName: "mime", stringValue: self.configRequestMime)

                let iq = XMPPIQ(type: "get", child: query)!
                iq.addAttribute(withName: "from", stringValue: self.username)
                iq.addAttribute(withName: "id", stringValue: self.id)
                sender.send(iq)
                observer.onNext(sender)
                observer.onCompleted()
                return Disposables.create()
            }
            .flatMap { sender in
                return sender.rx_xmppStreamDidReceiveIq()
            }
            .observeOn(backgroundScheduler)
            .flatMap { sender, iq in
                return self.findConfiguration(in: iq)
            }
            .observeOn(MainScheduler.instance)
        

    }


    func findConfiguration(in iq: XMPPIQ) -> Observable<Configuration> {
        return Observable.create { observer in
            let result = self.handle(iq: iq)
            if let result = result {
                observer.onNext(result)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    func handle(iq message: XMPPIQ) -> Configuration? {
        guard message.isGet(), let to = message.recipient, to == username else {
            log.debug("receive iq message that has invalid attributes: \(message)")
            return nil
        }

        guard let value = try? message.getOaValue() else {
            return nil
        }

        let configuration = parseConfiguration(stringValue: value)

        return configuration
        
    }


    func parseConfiguration(stringValue value: String) -> Configuration? {
        guard let jsonValue = try? JSONSerialization.jsonObject(with: value.data(using: String.Encoding.utf8)!) else {
            return nil
        }
        guard let json = jsonValue as? [String: Any] else {
            return nil
        }
        return DefaultConfiguration(json: json)
    }
}
