//
//  TestAuthenticator.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 28/12/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import XCTest
import XMPPFramework

class TestAuthenticator: XCTestCase {

    fileprivate let log = Logger.get()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testStart() {
        let authenticator = DefaultAuthenticator()
        authenticator.start()
        XCTAssertTrue(authenticator.started)
    }

    func testStop() {
        let authenticator = DefaultAuthenticator()
        authenticator.start()
        XCTAssertTrue(authenticator.started)
        authenticator.stop()
        XCTAssertFalse(authenticator.started)
    }
    
    func testAuthenticationSucceeded() {
        let iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"get\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"200\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"
        let message: XMPPIQ?
        do {
            message = try XMPPIQ(xmlString: iqMessage)
        } catch {
            message = nil
            XCTFail("Failed initializing IQ message")
        }
        let authenticator = DefaultAuthenticator()
        XCTAssertEqual(authenticator.handle(iq: message!), AuthenticatorError.success)
        XCTAssertNotNil(authenticator.token)
        if let token = authenticator.token {
            XCTAssertEqual(token, "865b9699-cfc2-4bef-92fd-03ac2c45bbf0")
        }
    }

    func testAuthenticationFailedBecauseOfWrongIq() {
        // wrong type
        var iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"set\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"200\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"
        var message: XMPPIQ?
        do {
            message = try XMPPIQ(xmlString: iqMessage)
        } catch {
            message = nil
            XCTFail("Failed initializing IQ message")
        }
        var authenticator = DefaultAuthenticator()
        XCTAssertEqual(authenticator.handle(iq: message!), AuthenticatorError.invalidIqAttributes)
        XCTAssertNil(authenticator.token)

        // No identity field
        iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" type=\"get\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"200\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"

        do {
            message = try XMPPIQ(xmlString: iqMessage)
        } catch {
            message = nil
            XCTFail("Failed initializing IQ message")
        }
        authenticator = DefaultAuthenticator()
        XCTAssertEqual(authenticator.handle(iq: message!), AuthenticatorError.invalidIqAttributes)
        XCTAssertNil(authenticator.token)
    }

    func testAuthenticationFailedBecauseOfWrongOaValue() {
        // No status field
        var iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"get\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"200\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"
        var message: XMPPIQ?
        do {
            message = try XMPPIQ(xmlString: iqMessage)
        } catch {
            message = nil
            XCTFail("Failed initializing IQ message")
        }
        var authenticator = DefaultAuthenticator()
        XCTAssertEqual(authenticator.handle(iq: message!), AuthenticatorError.invalidOaValue)
        XCTAssertNil(authenticator.token)

        // No identity field
        iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"get\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"200\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"

        do {
            message = try XMPPIQ(xmlString: iqMessage)
        } catch {
            message = nil
            XCTFail("Failed initializing IQ message")
        }
        authenticator = DefaultAuthenticator()
        XCTAssertEqual(authenticator.handle(iq: message!), AuthenticatorError.invalidOaValue)
        XCTAssertNil(authenticator.token)
    }

    func testAuthenticationFailedBecauseOfWrongOa() {
        // No errorcode field
        var iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"get\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"
        var message: XMPPIQ?
        do {
            message = try XMPPIQ(xmlString: iqMessage)
        } catch {
            message = nil
            XCTFail("Failed initializing IQ message")
        }
        var authenticator = DefaultAuthenticator()
        XCTAssertEqual(authenticator.handle(iq: message!), AuthenticatorError.invalidOaErrorCode)
        XCTAssertNil(authenticator.token)


        // Wrong error code
        iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"get\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"100\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"

        do {
            message = try XMPPIQ(xmlString: iqMessage)
        } catch {
            message = nil
            XCTFail("Failed initializing IQ message")
        }
        authenticator = DefaultAuthenticator()
        XCTAssertEqual(authenticator.handle(iq: message!), AuthenticatorError.invalidOaErrorCode)
        XCTAssertNil(authenticator.token)


        // No oa child
        iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"get\"><toto xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"200\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</toto></iq>"

        do {
            message = try XMPPIQ(xmlString: iqMessage)
        } catch {
            message = nil
            XCTFail("Failed initializing IQ message")
        }
        authenticator = DefaultAuthenticator()
        XCTAssertEqual(authenticator.handle(iq: message!), AuthenticatorError.noOaChild)
        XCTAssertNil(authenticator.token)
    }

    func testValueParsingSuccess() {
        let value = "serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub"

        let authenticator = DefaultAuthenticator()
        let values = authenticator.parse(stringValue: value)
        XCTAssertFalse(values.isEmpty)
        XCTAssertNotNil(values["serverIdentity"])
        XCTAssertEqual(values["serverIdentity"], "865b9699-cfc2-4bef-92fd-03ac2c45bbf0")
        XCTAssertNotNil(values["status"])
        XCTAssertEqual(values["status"], "succeeded")
        XCTAssertNotNil(values["protocolVersion"])
        XCTAssertEqual(values["protocolVersion"], "{XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}")
        XCTAssertNotNil(values["hubProfiles"])
        XCTAssertEqual(values["hubProfiles"], "{Harmony=\"2.0\"}")
        XCTAssertNotNil(values["productId"])
        XCTAssertEqual(values["productId"], "Pimento")
        XCTAssertNotNil(values["friendlyName"])
        XCTAssertEqual(values["friendlyName"], "Harmony Hub")
    }

    func testValueParsingWithEmptyString() {
        let value = ""
        let authenticator = DefaultAuthenticator()
        let values = authenticator.parse(stringValue: value)
        XCTAssertTrue(values.isEmpty)
    }

    func testValueParsingWithSingleValue() {
        let key = String.any()
        let value = String.any()
        let strValue = key + "=" + value
        let authenticator = DefaultAuthenticator()
        let values = authenticator.parse(stringValue: strValue)
        XCTAssertEqual(values.count, 1)
        XCTAssertEqual(values[key], value)
    }

    func testValueParsingWithWrongSingleValue() {
        let str = String.any()
        var strValue = str + "="
        var authenticator = DefaultAuthenticator()
        var values = authenticator.parse(stringValue: strValue)
        XCTAssertEqual(values.count, 1)
        XCTAssertEqual(values[str], "")

        strValue = "=" + str
        authenticator = DefaultAuthenticator()
        values = authenticator.parse(stringValue: strValue)
        XCTAssertTrue(values.isEmpty)
    }

    func testValueParsingWithWrongValueSomewhere() {
        let str = String.any()
        let str2 = String.any()
        let value = String.any()
        let value2 = String.any()

        var strValue = str + "=" + value + ":" + str2 + "="
        var authenticator = DefaultAuthenticator()
        var values = authenticator.parse(stringValue: strValue)
        XCTAssertEqual(values.count, 2)
        XCTAssertEqual(values[str], value)
        XCTAssertEqual(values[str2], "")

        strValue = str + "=" + value + ":=" + value2
        authenticator = DefaultAuthenticator()
        values = authenticator.parse(stringValue: strValue)
        XCTAssertEqual(values.count, 1)
        XCTAssertEqual(values[str], value)

        strValue = "=" + value + ":=" + value2
        authenticator = DefaultAuthenticator()
        values = authenticator.parse(stringValue: strValue)
        XCTAssertTrue(values.isEmpty)

        strValue = "=:"
        authenticator = DefaultAuthenticator()
        values = authenticator.parse(stringValue: strValue)
        XCTAssertTrue(values.isEmpty)
    }


}
