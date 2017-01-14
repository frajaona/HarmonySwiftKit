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

    fileprivate let testIp = Config.testIp
    fileprivate let testUser = Config.testUser
    fileprivate let testPassword = Config.testPassword
    fileprivate let testId = Config.testId
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
        var e = expectation(description: "waiting device list")
        let deviceManager = DefaultDeviceManager(deviceService: DefaultDeviceService(stream: stream, ip: testIp, username: testUser, id: testId))

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

    func testCurrentActivityObservable() {
        let stream = RxXMPPStream()!
        let deviceManager = DefaultDeviceManager(deviceService: DefaultDeviceService(stream: stream, ip: testIp, username: testUser, id: testId))

        var e = expectation(description: "waiting device list")

        deviceManager.devices
            .subscribe(onNext: { devices in
                XCTAssertFalse(devices.isEmpty)
                e.fulfill()
            })
            .addDisposableTo(disposeBag)
        waitForExpectations(timeout: 20, handler: { error in
            if let error = error {
                XCTFail("testCurrentActivityObservable timed out: \(error)")
            }
        })


        e = expectation(description: "waiting current activity")

        // Use manual disposable here so it can be disposed right after waitForExpection
        // This prevent from being subscribed to more than one Observable at the same time
        var disposable = deviceManager.currentActivity
            .subscribe(onNext: { activity in
                e.fulfill()
            })
        waitForExpectations(timeout: 20, handler: { error in
            if let error = error {
                XCTFail("testCurrentActivityObservable timed out: \(error)")
            }
        })

        disposable.dispose()

        e = expectation(description: "waiting current activity")

        disposable = deviceManager.currentActivity
            .subscribe(onNext: { activity in
                e.fulfill()
            })
        waitForExpectations(timeout: 20, handler: { error in
            if let error = error {
                XCTFail("testCurrentActivityObservable timed out: \(error)")
            }
        })

        disposable.dispose()

        stream.close()
    }
    

    func testDeviceActionObservable() {
        let stream = RxXMPPStream()!
        var e = expectation(description: "waiting device list")
        var foundDevices: [Device]?
        let deviceManager = DefaultDeviceManager(deviceService: DefaultDeviceService(stream: stream, ip: testIp, username: testUser, id: testId))
        
        deviceManager.devices
            .subscribe(onNext: { devices in
                XCTAssertFalse(devices.isEmpty)
                e.fulfill()
                foundDevices = devices
            })
            .addDisposableTo(disposeBag)
        waitForExpectations(timeout: 20, handler: { error in
            if let error = error {
                XCTFail("testDeviceObservable timed out: \(error)")
            }
        })
        
        
        if let devices = foundDevices {
            let muteFunction = devices.first(where: { device in
                return device.name == "Naim Dac"
            })?
            .controlGroups
            .first(where: { group in
                return group.name == "Volume"
            })?
            .functions
            .first(where: { function in
                return function.name == "Mute"
            })
            if let action = muteFunction?.action {
                self.log.debug("sending click")
                e = expectation(description: "waiting click")
                deviceManager.click(action: action).subscribe(onNext: { success in
                    self.log.debug("click sent")
                    e.fulfill()
                })
                .addDisposableTo(disposeBag)
                waitForExpectations(timeout: 20, handler: { error in
                    if let error = error {
                        XCTFail("testDeviceActionObservable timed out: \(error)")
                    }
                })
            }
        }
        
        stream.close()
    }

      
}
