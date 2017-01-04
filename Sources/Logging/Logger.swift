//
//  LoggerConfig.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 28/12/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

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
