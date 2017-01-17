/*
 * Copyright (C) 2017 Fred Rajaona
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
