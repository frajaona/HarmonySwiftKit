//
//  Function.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 12/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation

/**
 Harmony Hub API Function
 */
public struct Function {

    /**
     The deserialized json object representing the object
     */
    fileprivate let json: [String: Any]

    /**
     The function's name
     */
    let name: String

    /**
     The function's label
     */
    let label: String

    /**
     The function's action
     */
    let action: Action

    /**
     Returns an instance of Function only if parsing succeeds

     - Parameter json: a deserialized json object

     */
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
