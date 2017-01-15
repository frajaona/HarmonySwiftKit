//
//  TestHarmonyHub.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 15/01/2017.
//  Copyright © 2017 Fred Rajaona. All rights reserved.
//

import XCTest
import RxSwift

class TestHarmonyHub: XCTestCase {
    
    let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGettingDeviceManager() {
        let hub = HarmonyHub(ip: Config.testIp)
        let e = expectation(description: "")
        hub.deviceManager
            .flatMap { deviceManager in
                return deviceManager.devices
            }
            .subscribe(onNext: { devices in
                XCTAssertFalse(devices.isEmpty)
                e.fulfill()
            })
            .addDisposableTo(disposeBag)
        waitForExpectations(timeout: 20, handler: { error in
            if let error = error {
                XCTFail("testGettingDeviceManager timed out: \(error)")
            }
        })
    }

}
