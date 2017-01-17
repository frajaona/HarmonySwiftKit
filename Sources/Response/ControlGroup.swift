//
//  ControlGroup.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 12/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation

/**
 Harmony Hub API Control Group
 
 A group gathers functions that interact with the same feature
 
 For instance, the Volume Control Group gathers the following functions: Volume Up, Volume Down, Mute
 */
public struct ControlGroup {

    /**
     The deserialized json object representing the object
     */
    fileprivate let json: [String: Any]

    /**
     The name of this Control Group
     */
    let name: String

    /**
     The functions associated with this group
     */
    let functions: [Function]

    /**
     Returns an instance of ControlGroup only if parsing succeeds

     - Parameter json: a deserialized json object

     */
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
