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
import SwiftyBeaver
import XMPPFramework

public class Logger {

    private static var ready = false

    public static func get() -> SwiftyBeaver.Type {
        let logger = SwiftyBeaver.self
        if !Logger.ready {
            Logger.ready = true
            logger.addDestination(ConsoleDestination())
            DDLog.add(DDTTYLogger.sharedInstance(), with: DDLogLevel.all)
        }
        return logger
    }
}
