//
//  Activity.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 10/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation

/**
 Harmony Hub API Activity
 */
public struct Activity {

    /**
     The deserialized json object representing the object
     */
    fileprivate let json: [String: Any]

    /**
     The name of this Activity
     */
    let name: String

    /**
     The id of this Activity
     */
    let id: String

    /**
     The type of this Activity
     */
    let type: String

    /**
     The Control Group list containing the function to interact with this Activity
     */
    let controlGroups: [ControlGroup]

    /**
     Returns an instance of Activity only if parsing succeeds

     - Parameter json: a deserialized json object

     */
    init?(json: [String: Any]) {
        self.json = json
        guard let name = json["label"] as? String,
            let id = json["id"] as? String,
            let type = json["type"] as? String,
            let list = json["controlGroup"] as? [[String: Any]] else {
            return nil
        }
        self.name = name
        self.id = id
        self.type = type
        self.controlGroups = list.flatMap { group in
            return ControlGroup(json: group)
        }
    }
}
