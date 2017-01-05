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

    
    func testAuthenticationSucceeded() {
        let iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"get\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"200\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"
        let message = try? XMPPIQ(xmlString: iqMessage)
        let authenticator = DefaultAuthenticator()
        let (result, token) = authenticator.handle(iq: message!)
        XCTAssertEqual(result, .success)
        XCTAssertEqual(token, "865b9699-cfc2-4bef-92fd-03ac2c45bbf0")
    }

    func testAuthenticationFailedBecauseOfWrongIq() {
        // wrong type
        var iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"set\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"200\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"
        var message = try? XMPPIQ(xmlString: iqMessage)
        var authenticator = DefaultAuthenticator()
        var (result, token) = authenticator.handle(iq: message!)
        XCTAssertEqual(result, .invalidIqAttributes)
        XCTAssertNil(token)

        // No identity field
        iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" type=\"get\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"200\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"

        message = try? XMPPIQ(xmlString: iqMessage)
        authenticator = DefaultAuthenticator()
        (result, token) = authenticator.handle(iq: message!)
        XCTAssertEqual(result, .invalidIqAttributes)
        XCTAssertNil(token)
    }

    func testAuthenticationFailedBecauseOfWrongOaValue() {
        // No status field
        var iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"get\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"200\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"
        var message = try? XMPPIQ(xmlString: iqMessage)
        var authenticator = DefaultAuthenticator()
        var (result, token) = authenticator.handle(iq: message!)
        XCTAssertEqual(result, .invalidOaValue)
        XCTAssertNil(token)

        // No identity field
        iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"get\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"200\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"

        message = try? XMPPIQ(xmlString: iqMessage)
        authenticator = DefaultAuthenticator()
        (result, token) = authenticator.handle(iq: message!)
        XCTAssertEqual(result, .invalidOaValue)
        XCTAssertNil(token)
    }

    func testAuthenticationFailedBecauseOfWrongOa() {
        // No errorcode field
        var iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"get\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"
        var message = try? XMPPIQ(xmlString: iqMessage)
        var authenticator = DefaultAuthenticator()
        var (result, token) = authenticator.handle(iq: message!)
        XCTAssertEqual(result, .invalidOaErrorCode)
        XCTAssertNil(token)


        // Wrong error code
        iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"get\"><oa xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"100\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</oa></iq>"

        message = try? XMPPIQ(xmlString: iqMessage)
        authenticator = DefaultAuthenticator()
        (result, token) = authenticator.handle(iq: message!)
        XCTAssertEqual(result, .invalidOaErrorCode)
        XCTAssertNil(token)


        // No oa child
        iqMessage = "<iq xmlns=\"jabber:client\" id=\"21345678-1234-5678-1234-123456789012-1\" to=\"guest\" type=\"get\"><toto xmlns=\"connect.logitech.com\" mime=\"vnd.logitech.connect/vnd.logitech.pair\" errorcode=\"200\" errorstring=\"OK\">serverIdentity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:hubId=106:identity=865b9699-cfc2-4bef-92fd-03ac2c45bbf0:status=succeeded:protocolVersion={XMPP=\"1.0\", HTTP=\"1.0\", RF=\"1.0\", WEBSOCKET=\"1.0\"}:hubProfiles={Harmony=\"2.0\"}:productId=Pimento:friendlyName=Harmony Hub</toto></iq>"

        message = try? XMPPIQ(xmlString: iqMessage)
        authenticator = DefaultAuthenticator()
        (result, token) = authenticator.handle(iq: message!)
        XCTAssertEqual(result, .noOaChild)
        XCTAssertNil(token)
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
        let str = "dfsfsdfnkjjknlpkml,"
        let str2 = "dpoiuutrtr"
        let value = "wxcvc"
        let value2 = "gfdfdkjh"

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
