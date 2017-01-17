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

/**
 The different commands that can be sent to a Harmony Hub
 */
enum CommandType: String {
    /**
     Request Configuration
     */
    case getConfiguration = "config"
    /**
     Execute Action
     */
    case executeAction = "holdAction"
    /**
     Request current Activity
     */
    case getCurrentActivity = "getCurrentActivity"
    /**
     Start Activity
     */
    case startActivity = "startactivity"
}

/**
 The Command protocol defines a generic command that can be sent to a Harmony Hub.
 
 The Command is sent through a XMPP IQ message that contains an \<oa\> tag filled with the command arguments
 */
protocol Command {

    /**
     The type of the command to send
     */
    var type: CommandType { get }

    /**
     The \<oa\> value to add if any
     */
    var oaValue: String? { get }

    /**
     Observable sequence of RxXMPPStream for executing a command.

     Command execution starts after observer is subscribed and not after invoking this method.

     **Execution will be performed per subscribed observer.**

     - parameter sender: stream used to send the command
     - parameter username: username used as sender for the command
     - parameter id: id used for the IQ message
     - returns: Observable sequence of RxXMPPStream.
     */
    func executeRequest(sender: RxXMPPStream, username: String, id: String) -> Observable<RxXMPPStream>

}

extension Command {

    /**
     Logitech xmlns
     */
    fileprivate var xmlns: String {
        return "connect.logitech.com"
    }

    /**
     Logitech mime
     */
    fileprivate var configRequestMime: String {
        return "vnd.logitech.harmony/vnd.logitech.harmony.engine?"
    }


    var oaValue: String? {
        // Default implementation does not need an \<oa\> value
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

/**
 Command for requesting Harmony Hub Configuration
 */
struct GetConfigurationCommand: Command {

    let type: CommandType = .getConfiguration
}

/**
 Command for requesting current Activity
 */
struct GetCurrentActivityCommand: Command {

    let type: CommandType = .getCurrentActivity
}

/**
 Command for starting an Activity
 */
struct StartActivityCommand: Command {

    let type: CommandType = .startActivity

    /**
     The id of the Activity to start
     */
    fileprivate let activityId: Int

    /**
     Return an instance of StartActivityCommand
     
     - parameter activityId: The id of the Activity to start
     */
    init(activityId: Int) {
        self.activityId = activityId
    }

    var oaValue: String? {
        return "activityId=\(activityId):timestamp=0"
    }

}

/**
 Command for executing a device's action
 */
struct ExecuteActionCommand: Command {

    let type: CommandType = .executeAction

    /**
     The Action that this command will send
     */
    fileprivate let action: Action

    /**
     The state to use: release / press
     */
    fileprivate let state: String

    /**
     Return an instance of ExecuteActionCommand

     - parameter action: The Action that this command will send
     - parameter pressed: True for 'press' state, false for 'release'
     */
    init(action: Action, pressed: Bool) {
        self.action = action
        state = pressed ? "press" : "release"
    }

    var oaValue: String? {
        return "action={\"type\"::\"\(action.type)\",\"deviceId\"::\"\(action.deviceId)\",\"command\"::\"\(action.command)\"}:status=\(state)"
    }
}

/**
 Command for simulating a click on a device button
 
 A click command is a chain of two ExecuteActionCommand command, one with a 'press' status,
 a second with a 'release' status
 */
struct ClickCommand: Command {

    let type: CommandType = .executeAction

    /**
     The 'press' command
     */
    fileprivate let pressCommand: ExecuteActionCommand

    /**
     The 'release' command
     */
    fileprivate let releaseCommand: ExecuteActionCommand

    /**
     The delay between the 'press' and 'release' command
     */
    fileprivate let delay: TimeInterval


    /**
     Return an instance of ClickCommand

     - parameter action: The Action that this command will send
     - parameter delay: The delay between the 'press' and 'release' command
     */
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


