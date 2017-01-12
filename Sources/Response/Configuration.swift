//
//  Configuration.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 10/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation

protocol Configuration {

    var activities: [Activity]? { get }

    var devices: [Device]? { get }
}

struct DefaultConfiguration: Configuration {

    fileprivate let json: [String: Any]

    let activities: [Activity]?

    let devices: [Device]?

    let content: Any?

    init(json: [String: Any]) {
        self.json = json
        if let list = json["activity"] as? [[String: Any]] {
            self.activities = list.flatMap { activity in
                return Activity(json: activity)
            }
        } else {
            self.activities = nil
        }
        if let list = json["device"] as? [[String: Any]] {
            self.devices = list.flatMap { device in
                return Device(json: device)
            }
        } else {
            self.devices = nil
        }
        self.content = json["content"]
    }

}
