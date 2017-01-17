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
 Harmony Hub API Action
 */
public struct Action {

    /**
     The raw action string
     */
    fileprivate let action: String

    /**
     The action name
     */
    let command: String

    /**
     The Id of the device that handles this action
     */
    let deviceId: String

    /**
     The type of the action
     */
    let type: String

    /**
     Returns an instance of Action only if parsing succeeds
     
     - Parameter action: The raw action string to parse
     
     */
    init?(action: String) {
        self.action = action
        guard let jsonValue = try? JSONSerialization.jsonObject(with: action.data(using: String.Encoding.utf8)!),
            let json = jsonValue as? [String: Any],
            let command = json["command"] as? String,
            let deviceId = json["deviceId"] as? String,
            let type = json["type"] as? String else {
            return nil
        }
        self.command = command
        self.deviceId = deviceId
        self.type = type
    }
}
