//
//  TestDeviceManager.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 11/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import XCTest
import RxSwift

class TestDeviceManager: XCTestCase {

    fileprivate let testIp = "192.168.240.156"
    fileprivate let testUser = "865b9699-cfc2-4bef-92fd-03ac2c45bbf0"
    fileprivate let testPassword = "865b9699-cfc2-4bef-92fd-03ac2c45bbf0"
    fileprivate let testId = "21345678-1234-5678-1234-123456789012-1"
    fileprivate let log = Logger.get()
    fileprivate let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDeviceObservable() {
        let stream = RxXMPPStream()!
        signinStream(stream: stream)
        var e = expectation(description: "waiting device list")
        let deviceManager = DefaultDeviceManager(deviceService: DefaultDeviceService(stream: stream, username: testUser, id: testId))

        deviceManager.devices
            .subscribe(onNext: { devices in
                XCTAssertFalse(devices.isEmpty)
                e.fulfill()
            })
            .addDisposableTo(disposeBag)
        waitForExpectations(timeout: 20, handler: { error in
            if let error = error {
                XCTFail("testDeviceObservable timed out: \(error)")
            }
        })

        e = expectation(description: "waiting cached device list")
        deviceManager.activities
            .subscribe(onNext: { activities in
                XCTAssertFalse(activities.isEmpty)
                e.fulfill()
            })
            .addDisposableTo(disposeBag)
        waitForExpectations(timeout: 20, handler: { error in
            if let error = error {
                XCTFail("testDeviceObservable timed out: \(error)")
            }
        })

        stream.close()
    }

    fileprivate func signinStream(stream: RxXMPPStream) {
        let e = expectation(description: "signed in time")
        let connector = DefaultConnector(with: stream, authenticator: DefaultAuthenticator(), ip: testIp, username: testUser + "@x.com", password: testPassword)
        connector.connect()
            .subscribe(onNext: { result in
                self.log.debug("signed result: \(result)")
                XCTAssertEqual(result, .success)
                e.fulfill()
            })
            .addDisposableTo(disposeBag)

        waitForExpectations(timeout: 20, handler:  { error in
            if let error = error {
                XCTFail("signing timed out: \(error)")
            }
        })
    }
}
