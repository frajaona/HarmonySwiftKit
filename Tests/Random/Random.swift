//
//  Random.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 29/12/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

extension String {

    /**
     Utility function used to generate a random String
    */
    static func any(maxLength: UInt32 = 128) -> String {
        let charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\\/,;{}\"'123456789+-*°)_!§(&¨^$€£`%.<>@#"
        var c = charSet.characters.map { String($0) }
        var s:String = ""
        let length = Int(arc4random() % maxLength)
        if length != 0 {
            for _ in (1...length) {
                s.append(c[Int(arc4random()) % c.count])
            }
        }
        return s
    }
}
