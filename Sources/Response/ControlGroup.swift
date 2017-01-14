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

    let name: String
    let functions: [Function]

    init?(json: [String: Any]) {
        self.json = json
        guard let name = json["name"] as? String,
            let list = json["function"] as? [[String: Any]] else {
            return nil
        }
        self.name = name
        self.functions = list.flatMap { function in
            return Function(json: function)
        }
    }
}
