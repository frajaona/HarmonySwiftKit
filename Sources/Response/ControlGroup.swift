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
