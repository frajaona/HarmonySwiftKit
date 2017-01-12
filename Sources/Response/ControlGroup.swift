//
//  ControlGroup.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 12/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation

struct ControlGroup {

    let json: [String: Any]

    let name: String?
    let functions: [Function]?

    init(json: [String: Any]) {
        self.json = json
        self.name = json["name"] as? String
        if let list = json["function"] as? [[String: Any]] {
            self.functions = list.flatMap { function in
                return Function(json: function)
            }
        } else {
            self.functions = nil
        }
    }
}
