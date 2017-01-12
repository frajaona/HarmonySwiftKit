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

    let name: String?
    let label: String?
    let action: Action?

    init(json: [String: Any]) {
        self.json = json
        self.name = json["name"] as? String
        self.label = json["label"] as? String
        if let rawAction = json["action"] as? String {
            self.action = Action(action: rawAction)
        } else {
            self.action = nil
        }
    }
}
