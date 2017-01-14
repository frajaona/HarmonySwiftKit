//
//  Function.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 12/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation

struct Function {

    let json: [String: Any]

    let name: String
    let label: String
    let action: Action

    init?(json: [String: Any]) {
        self.json = json
        guard  let name = json["name"] as? String,
            let label = json["label"] as? String,
            let rawAction = json["action"] as? String,
            let action = Action(action: rawAction) else {
            return nil
        }
        self.name = name
        self.label = label
        self.action = action
    }
}
