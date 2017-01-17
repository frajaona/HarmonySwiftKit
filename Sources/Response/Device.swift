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
