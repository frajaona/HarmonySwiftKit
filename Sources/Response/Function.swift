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
 Harmony Hub API Function
 */
public struct Function {

    /**
     The deserialized json object representing the object
     */
    fileprivate let json: [String: Any]

    /**
     The function's name
     */
    let name: String

    /**
     The function's label
     */
    let label: String

    /**
     The function's action
     */
    let action: Action

    /**
     Returns an instance of Function only if parsing succeeds

     - Parameter json: a deserialized json object

     */
    init?(json: [String: Any]) {
        self.json = json
        guard  let name = json["name"] as? String,
            let label = json["label"] as? String,
            let rawAction = json["action"] as? String,
            let action = Action(action: rawAction) else {
            return nil
        }
        self.name = name
        self.label = label
        self.action = action
    }
}
