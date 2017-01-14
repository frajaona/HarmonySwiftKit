//
//  Action.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 12/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation

public struct Action {

    fileprivate let action: String

    let command: String

    let deviceId: String

    let type: String

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
