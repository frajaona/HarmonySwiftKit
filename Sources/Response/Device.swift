//
//  Device.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 10/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation

/**
 Harmony Hub API Device
 */
public struct Device {

    /**
     The deserialized json object representing the object
     */
    fileprivate let json: [String: Any]

    /**
     The name of this Device
     */
    let name: String

    /**
     The id of this device
     */
    let id: String

    /**
     The type of this device
     */
    let type: String

    /**
     The Control Group list containing the function to interact with this device
     */
    let controlGroups: [ControlGroup]

    /**
     Returns an instance of Device only if parsing succeeds

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
