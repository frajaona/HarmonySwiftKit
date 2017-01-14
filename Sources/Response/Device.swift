//
//  Device.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 10/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation

public struct Device {

    fileprivate let json: [String: Any]

    let name: String

    let id: String

    let type: String

    let controlGroups: [ControlGroup]

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
