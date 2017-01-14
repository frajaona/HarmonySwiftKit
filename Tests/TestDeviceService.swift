//
//  TestDeviceService.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 09/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import XCTest
import RxSwift

class TestDeviceService: XCTestCase {

    fileprivate let disposeBag = DisposeBag()
    fileprivate let testIp = Config.testIp
    fileprivate let testUser = Config.testUser
    fileprivate let testPassword = Config.testPassword
    fileprivate let testId = Config.testId
    fileprivate let log = Logger.get()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadingConfiguration() {
        let stream = RxXMPPStream()!
        signinStream(stream: stream)
        let e = expectation(description: "waiting device list")
        let deviceService = DefaultDeviceService(stream: stream, ip: testIp, username: testUser, id: testId)
        deviceService.configuration()
            .subscribe(onNext: { configuration in
                XCTAssertNotNil(configuration.devices)
                if let devices = configuration.devices {
                    XCTAssertFalse(devices.isEmpty)
                }
                e.fulfill()
            })
            .addDisposableTo(disposeBag)

        waitForExpectations(timeout: 20, handler: { error in
            if let error = error {
                XCTFail("testLoadingDeviceList timed out: \(error)")
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
