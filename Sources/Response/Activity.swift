//
//  Activity.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 10/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation

public struct Activity {

    fileprivate let json: [String: Any]

    let name: String?

    let id: String?

    let type: String?

    let controlGroups: [ControlGroup]?

    init(json: [String: Any]) {
        self.json = json
        self.name = json["label"] as? String
        self.id = json["id"] as? String
        self.type = json["type"] as? String
        if let list = json["controlGroup"] as? [[String: Any]] {
            self.controlGroups = list.flatMap { group in
                return ControlGroup(json: group)
            }
        } else {
            self.controlGroups = nil
        }
    }
}
