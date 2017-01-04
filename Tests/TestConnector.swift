//
//  TestConnector.swift
//  HarmonySwiftKit
//
//  Created by Fred Rajaona on 23/12/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class TestConnector: XCTestCase {

    fileprivate let log = Logger.get()
    fileprivate let disposeBag = DisposeBag()
    fileprivate var observer: TestableObserver<Bool>!

    override func setUp() {
        super.setUp()
        let scheduler = TestScheduler(initialClock: 0)
        observer = scheduler.createObserver(Bool.self)
        scheduler.start()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConnectSuccess() {
        var e = expectation(description: "first connection process ended")
        let stream = RxXMPPStream()!
        let connector = DefaultConnector(with: stream, authenticator: DefaultAuthenticator())
        connector.connected
            .asObservable()
            .subscribe(observer)
            .addDisposableTo(disposeBag)
        XCTAssertEqual(observer.events.count, 1)
        connector.connect()
            .subscribe(onNext: { result in
                self.log.debug("first connected process succeeded")
                e.fulfill()
            }).addDisposableTo(disposeBag)

        waitForExpectations(timeout: 20, handler:  { error in
            if let error = error {
                XCTFail("first testConnectSuccess timed out: \(error)")
            }
        })
        
        XCTAssertEqual(observer.events.count, 2)

        e = expectation(description: "second connection process ended")
        
        connector.connect()
            .subscribe(onNext: { result in
                self.log.debug("second connected process succeeded")
                e.fulfill()
            }).addDisposableTo(disposeBag)

        waitForExpectations(timeout: 20, handler:  { error in
            if let error = error {
                XCTFail("second testConnectSuccess timed out: \(error)")
            }
        })
        
        XCTAssertEqual(observer.events.count, 2)
    }

    
}
