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

import XMPPFramework

/**
 XMPPIQ parsing errors
 */
enum XMPPIQError: Error {
    /// No <oa> child found in IQ
    case noOaChild
    /// Invalide error code found in <oa> element
    case invalidOaErrorCode
    /// <oa> element has no value
    case noOaValue
    /// <oa> element has an invalid value
    case invalidOaValue
}

extension XMPPIQ {

    /**
     Get \<oa\> value contained in this XMPP IQ message
     
     Throw a XMPPIQError if it cannot find a value
     
     - returns: <oa> string value
    */
    func getOaValue() throws -> String {
        let log = Logger.get()

        guard let child = childElement(), let name = child.name, name == "oa" else {
            log.debug("receive iq message that does not contain an oa child: \(self)")
            throw XMPPIQError.noOaChild
        }

        guard let errorCode = child.attributeStringValue(forName: "errorcode"), errorCode == "200" else {
            log.debug("receive iq message containing an oa child with an invalid errorcode: \(child)")
            throw XMPPIQError.invalidOaErrorCode
        }

        guard let value = stringValue else {
            log.debug("receive iq message containing an oa that does not have a value: \(child)")
            throw XMPPIQError.noOaValue
        }

        return value
    }

    /**
     Get the \"to\" attribute value contained in this XMPP IQ message

     - returns: The attribute value if found, nil otherwise
     */
    var recipient: String? {
        return attributeStringValue(forName: "to")
    }
}
