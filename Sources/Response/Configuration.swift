//
//  Configuration.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 10/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import Foundation

/**
 A Configuration holds the activity and device lists
 */
protocol Configuration {

    /**
     The available Activity list
     */
    var activities: [Activity] { get }

    /**
     The available Device list
     */
    var devices: [Device] { get }
}

/**
 Harmony Hub API Configuration
 */
struct DefaultConfiguration: Configuration {

    /**
     The deserialized json object representing the object
     */
    fileprivate let json: [String: Any]


    let activities: [Activity]


    let devices: [Device]

    /**
     To be documented
     */
    fileprivate let content: Any

    /**
     Returns an instance of DefaultConfiguration only if parsing succeeds

     - Parameter json: a deserialized json object

     */
    init?(json: [String: Any]) {
        self.json = json
        guard let activityList = json["activity"] as? [[String: Any]],
            let deviceList = json["device"] as? [[String: Any]],
            let content = json["content"] else {
            return nil
        }
        self.devices = deviceList.flatMap { device in
            return Device(json: device)
        }
        self.activities = activityList.flatMap { activity in
            return Activity(json: activity)
        }
        self.content = content
    }

}
