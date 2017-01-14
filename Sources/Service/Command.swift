//
//  Command.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 13/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation
import XMPPFramework
import RxSwift

enum CommandType: String {
    case getConfiguration = "config"
    case executeAction = "holdAction"
    case getCurrentActivity = "getCurrentActivity"
    case startActivity = "startactivity"
}

protocol Command {

    var type: CommandType { get }
    var oaValue: String? { get }
    func executeRequest(sender: RxXMPPStream, username: String, id: String) -> Observable<RxXMPPStream>

}

extension Command {
    fileprivate var xmlns: String {
        return "connect.logitech.com"
    }

    fileprivate var configRequestMime: String {
        return "vnd.logitech.harmony/vnd.logitech.harmony.engine?"
    }

    var oaValue: String? {
        return nil
    }

    func executeRequest(sender: RxXMPPStream, username: String, id: String) -> Observable<RxXMPPStream> {
        return Observable<RxXMPPStream>.create { observer in
            let query = XMLElement(name: "oa", xmlns: self.xmlns)!
            query.addAttribute(withName: "mime", stringValue: self.configRequestMime + self.type.rawValue)
            if let oaValue = self.oaValue {
                query.stringValue = oaValue
            }

            let iq = XMPPIQ(type: "get", child: query)!
            iq.addAttribute(withName: "from", stringValue: username)
            iq.addAttribute(withName: "id", stringValue: id)
            sender.send(iq)
            observer.onNext(sender)
            observer.onCompleted()
            return Disposables.create()
        }
    }

}

struct GetConfigurationCommand: Command {

    let type: CommandType = .getConfiguration
}

struct GetCurrentActivityCommand: Command {

    let type: CommandType = .getCurrentActivity
}

struct StartActivityCommand: Command {

    let type: CommandType = .startActivity

    fileprivate let activityId: Int

    init(activityId: Int) {
        self.activityId = activityId
    }

    var oaValue: String? {
        return "activityId=\(activityId):timestamp=0"
    }

}


struct ClickCommand: Command {

    let type: CommandType = .executeAction

    fileprivate let pressCommand: ExecuteActionCommand
    fileprivate let releaseCommand: ExecuteActionCommand
    fileprivate let delay: TimeInterval

    init(action: Action, delay: TimeInterval = 0.1) {
        self.pressCommand = ExecuteActionCommand(action: action, pressed: true)
        self.releaseCommand = ExecuteActionCommand(action: action, pressed: false)
        self.delay = delay
    }

    func executeRequest(sender: RxXMPPStream, username: String, id: String) -> Observable<RxXMPPStream> {
        return pressCommand
            .executeRequest(sender: sender, username: username, id: id)
            .delay(self.delay, scheduler: MainScheduler.instance)
            .flatMap { sender in
                return self.releaseCommand.executeRequest(sender: sender, username: username, id: id)
            }
    }
}

struct ExecuteActionCommand: Command {

    let type: CommandType = .executeAction

    fileprivate let action: Action

    fileprivate let state: String

    init(action: Action, pressed: Bool) {
        self.action = action
        state = pressed ? "press" : "release"
    }

    var oaValue: String? {
        return "action={\"type\"::\"\(action.type!)\",\"deviceId\"::\"\(action.deviceId!)\",\"command\"::\"\(action.command!)\"}:status=\(state)"
    }
}
