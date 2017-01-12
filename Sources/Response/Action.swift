//
//  Action.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 12/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation

struct Action {

    let action: String

    let command: String?

    let deviceId: String?

    let type: String?

    init(action: String) {
        self.action = action
        if let jsonValue = try? JSONSerialization.jsonObject(with: action.data(using: String.Encoding.utf8)!), let json = jsonValue as? [String: Any] {
            self.command = json["command"] as? String
            self.deviceId = json["deviceId"] as? String
            self.type = json["type"] as? String
        } else {
            self.command = nil
            self.deviceId = nil
            self.type = nil
        }
    }
}
