//
//  RxXMPPStream.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 30/12/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import XCTest
import XMPPFramework
import RxSwift
import RxCocoa
import RxTest

class TestRxXMPPStream: XCTestCase {

    private var observer: TestableObserver<RxXMPPStream>!
    private var defaultMessageObserver: TestableObserver<(RxXMPPStream, XMPPMessage)>!
    private var iqMessageObserver: TestableObserver<(RxXMPPStream, XMPPIQ)>!
    private let stream = RxXMPPStream()
    private let bag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let scheduler = TestScheduler(initialClock: 0)
        observer = scheduler.createObserver(RxXMPPStream.self)
        defaultMessageObserver = scheduler.createObserver((RxXMPPStream, XMPPMessage).self)
        iqMessageObserver = scheduler.createObserver((RxXMPPStream, XMPPIQ).self)

        scheduler.start()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testReceiveXmppStreamWillConnect() {
        _ = stream?.rx_xmppStreamWillConnect()
            .subscribe(observer)
            .addDisposableTo(bag)
        XCTAssertNotNil(stream?.delegate)
        XCTAssertEqual(observer.events.count, 0)
        if let delegate = stream?.delegate {
            delegate.xmppStreamWillConnect!(stream)
        }
        XCTAssertEqual(observer.events.count, 1)

        if let delegate = stream?.delegate {
            delegate.xmppStreamWillConnect!(stream)
        }
        XCTAssertEqual(observer.events.count, 2)
    }

    func testReceiveXmppStreamDidConnect() {
        _ = stream?.rx_xmppStreamDidConnect()
            .subscribe(observer)
            .addDisposableTo(bag)
        XCTAssertNotNil(stream?.delegate)
        XCTAssertEqual(observer.events.count, 0)
        if let delegate = stream?.delegate {
            delegate.xmppStreamDidConnect!(stream)
        }
        XCTAssertEqual(observer.events.count, 1)

        if let delegate = stream?.delegate {
            delegate.xmppStreamDidConnect!(stream)
        }
        XCTAssertEqual(observer.events.count, 2)
    }

    func testReceiveXmppStreamConnectDidTimeout() {
        _ = stream?.rx_xmppStreamConnectDidTimeout()
            .subscribe(observer)
            .addDisposableTo(bag)
        XCTAssertNotNil(stream?.delegate)
        XCTAssertEqual(observer.events.count, 0)
        if let delegate = stream?.delegate {
            delegate.xmppStreamConnectDidTimeout!(stream)
        }
        XCTAssertEqual(observer.events.count, 1)

        if let delegate = stream?.delegate {
            delegate.xmppStreamConnectDidTimeout!(stream)
        }
        XCTAssertEqual(observer.events.count, 2)
    }

    func testReceiveXmppDidReceiveMessage() {
        var message = XMPPMessage(name: "test")
        _ = stream?.rx_xmppStreamDidReceiveXMPPMessage()
            .subscribe(defaultMessageObserver)
            .addDisposableTo(bag)
        XCTAssertNotNil(stream?.delegate)
        XCTAssertEqual(defaultMessageObserver.events.count, 0)
        if let delegate = stream?.delegate {
            delegate.xmppStream!(stream, didReceive: message)
        }
        XCTAssertEqual(observer.events.count, 0)
        XCTAssertEqual(defaultMessageObserver.events.count, 1)
        if defaultMessageObserver.events.count == 1, let receivedMessage = defaultMessageObserver.events[0].value.element?.1 {
            XCTAssertEqual(receivedMessage, message)
            XCTAssertEqual(message.name, "test")
        } else {
            XCTFail("Failed retrieving message")
        }

        message = XMPPMessage(name: "test2")
        if let delegate = stream?.delegate {
            delegate.xmppStream!(stream, didReceive: message)
        }
        XCTAssertEqual(observer.events.count, 0)
        XCTAssertEqual(defaultMessageObserver.events.count, 2)
        if defaultMessageObserver.events.count == 2, let receivedMessage = defaultMessageObserver.events[1].value.element?.1 {
            XCTAssertEqual(receivedMessage, message)
            XCTAssertEqual(message.name, "test2")
        } else {
            XCTFail("Failed retrieving message")
        }
    }

    func testReceiveXmppDidReceiveIq() {
        var message = XMPPIQ(name: "test")
        _ = stream?.rx_xmppStreamDidReceiveIq()
            .subscribe(iqMessageObserver)
            .addDisposableTo(bag)
        XCTAssertNotNil(stream?.delegate)
        XCTAssertEqual(iqMessageObserver.events.count, 0)
        if let delegate = stream?.delegate {
            XCTAssertFalse(delegate.xmppStream!(stream, didReceive: message))
        }
        XCTAssertEqual(observer.events.count, 0)
        XCTAssertEqual(defaultMessageObserver.events.count, 0)
        XCTAssertEqual(iqMessageObserver.events.count, 1)
        if iqMessageObserver.events.count == 1, let receivedMessage = iqMessageObserver.events[0].value.element?.1 {
            XCTAssertEqual(receivedMessage, message)
            XCTAssertEqual(message.name, "test")
        } else {
            XCTFail("Failed retrieving message")
        }

        message = XMPPIQ(name: "test2")
        if let delegate = stream?.delegate {
            XCTAssertFalse(delegate.xmppStream!(stream, didReceive: message))
        }
        XCTAssertEqual(observer.events.count, 0)
        XCTAssertEqual(defaultMessageObserver.events.count, 0)
        XCTAssertEqual(iqMessageObserver.events.count, 2)
        if iqMessageObserver.events.count == 2, let receivedMessage = iqMessageObserver.events[1].value.element?.1 {
            XCTAssertEqual(receivedMessage, message)
            XCTAssertEqual(message.name, "test2")
        } else {
            XCTFail("Failed retrieving message")
        }
    }

    func testReceiveXmppWillBind() {
        _ = stream?.rx_xmppStreamConnectWillBind()
            .subscribe(observer)
            .addDisposableTo(bag)
        XCTAssertNotNil(stream?.delegate)
        XCTAssertEqual(observer.events.count, 0)
        if let delegate = stream?.delegate {
            XCTAssertNil(delegate.xmppStreamWillBind!(stream))
        }
        XCTAssertEqual(observer.events.count, 1)

        if let delegate = stream?.delegate {
            XCTAssertNil(delegate.xmppStreamWillBind!(stream))
        }
        XCTAssertEqual(observer.events.count, 2)
    }

    func testReceiveXmppStreamDidAuthenticate() {
        _ = stream?.rx_xmppStreamDidAuthenticate()
            .subscribe(observer)
            .addDisposableTo(bag)
        XCTAssertNotNil(stream?.delegate)
        XCTAssertEqual(observer.events.count, 0)
        if let delegate = stream?.delegate {
            delegate.xmppStreamDidAuthenticate!(stream)
        }
        XCTAssertEqual(observer.events.count, 1)

        if let delegate = stream?.delegate {
            delegate.xmppStreamDidAuthenticate!(stream)
        }
        XCTAssertEqual(observer.events.count, 2)
    }
    
}
