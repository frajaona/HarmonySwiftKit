//
//  Action.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 12/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation

/**
 Harmony Hub API Action
 */
public struct Action {

    /**
     The raw action string
     */
    fileprivate let action: String

    /**
     The action name
     */
    let command: String

    /**
     The Id of the device that handles this action
     */
    let deviceId: String

    /**
     The type of the action
     */
    let type: String

    /**
     Returns an instance of Action only if parsing succeeds
     
     - Parameter action: The raw action string to parse
     
     */
    init?(action: String) {
        self.action = action
        guard let jsonValue = try? JSONSerialization.jsonObject(with: action.data(using: String.Encoding.utf8)!),
            let json = jsonValue as? [String: Any],
            let command = json["command"] as? String,
            let deviceId = json["deviceId"] as? String,
            let type = json["type"] as? String else {
            return nil
        }
        self.command = command
        self.deviceId = deviceId
        self.type = type
    }
}
