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
import XMPPFramework

class TestConnector: XCTestCase {


    fileprivate let testIp = Config.testIp
    fileprivate let testUsername = "guest@x.com"
    fileprivate let testPassword = "guest"
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

    func testSignIn() {
        let e = expectation(description: "first connection process ended")
        let stream = RxXMPPStream()!
        let connector = DefaultConnector(with: stream, authenticator: DefaultAuthenticator(), ip: testIp, username: "865b9699-cfc2-4bef-92fd-03ac2c45bbf0@x.com", password: "865b9699-cfc2-4bef-92fd-03ac2c45bbf0")
        connector.connect()
            .subscribe(onNext: { result in
                self.log.debug("first connected process returned: \(result)")
                XCTAssertEqual(result, .success)
                e.fulfill()
            })
            .addDisposableTo(disposeBag)

        waitForExpectations(timeout: 20, handler:  { error in
            if let error = error {
                XCTFail("first testConnectSuccess timed out: \(error)")
            }
        })
        stream.close()
    }
    
    func testConnectSuccess() {
        var e = expectation(description: "first connection process ended")
        let stream = RxXMPPStream()!
        let connector = DefaultConnector(with: stream, authenticator: DefaultAuthenticator(), ip: testIp, username: testUsername, password: testPassword)
        connector.connected
            .asObservable()
            .subscribe(observer)
            .addDisposableTo(disposeBag)
        XCTAssertEqual(observer.events.count, 1)
        connector.connect()
            .subscribe(onNext: { result in
                self.log.debug("first connected process returned: \(result)")
                XCTAssertEqual(result, .success)
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
                self.log.debug("second connected process returned: \(result)")
                XCTAssertEqual(result, .success)
                e.fulfill()
            }).addDisposableTo(disposeBag)

        waitForExpectations(timeout: 20, handler:  { error in
            if let error = error {
                XCTFail("second testConnectSuccess timed out: \(error)")
            }
        })
        
        XCTAssertEqual(observer.events.count, 2)
        stream.close()
    }

    func testConnectFailureOnRequestingAuthentication() {
        let e = expectation(description: "first connection process ended")
        class MockRxXMPPStream: RxXMPPStream {

            override func authenticate(_ auth: XMPPSASLAuthentication!) throws {
                throw AuthenticatorError.failedStartingAuthentication
            }
        }
        let stream = MockRxXMPPStream()!
        let connector = DefaultConnector(with: stream, authenticator: DefaultAuthenticator(), ip: testIp, username: testUsername, password: testPassword)
        connector.connected
            .asObservable()
            .subscribe(observer)
            .addDisposableTo(disposeBag)
        XCTAssertEqual(observer.events.count, 1)
        connector.connect()
            .subscribe(onNext: { result in
                self.log.debug("first connected process returned: \(result)")
                XCTAssertEqual(result, .failedRequestingAuthentication)
                e.fulfill()
            }).addDisposableTo(disposeBag)

        waitForExpectations(timeout: 20, handler:  { error in
            if let error = error {
                XCTFail("first testConnectSuccess timed out: \(error)")
            }
        })
        stream.close()

    }

    func testConnectFailureOnConnectRequest() {
        let e = expectation(description: "first connection process ended")
        class MockRxXMPPStream: RxXMPPStream {

            override func connect(withTimeout timeout: TimeInterval) throws {
                throw ConnectorError.failedStartingConnection
            }

        }
        let stream = MockRxXMPPStream()!
        let connector = DefaultConnector(with: stream, authenticator: DefaultAuthenticator(), ip: testIp, username: testUsername, password: testPassword)
        connector.connected
            .asObservable()
            .subscribe(observer)
            .addDisposableTo(disposeBag)
        XCTAssertEqual(observer.events.count, 1)
        connector.connect()
            .subscribe(onNext: { result in
                self.log.debug("first connected process returned: \(result)")
                XCTAssertEqual(result, .failedStartingConnection)
                e.fulfill()
            }).addDisposableTo(disposeBag)

        waitForExpectations(timeout: 20, handler:  { error in
            if let error = error {
                XCTFail("first testConnectSuccess timed out: \(error)")
            }
        })
        stream.close()
        
    }

    func testConnectFailureOnStartingConnection() {
        let e = expectation(description: "first connection process ended")
        class MockRxXMPPStream: RxXMPPStream {

            override func rx_connect(with timeout: TimeInterval) -> Observable<Bool> {
                return Observable.just(false)
            }

        }
        let stream = MockRxXMPPStream()!
        let connector = DefaultConnector(with: stream, authenticator: DefaultAuthenticator(), ip: testIp, username: testUsername, password: testPassword)
        connector.connected
            .asObservable()
            .subscribe(observer)
            .addDisposableTo(disposeBag)
        XCTAssertEqual(observer.events.count, 1)
        connector.connect()
            .subscribe(onNext: { result in
                self.log.debug("first connected process returned: \(result)")
                XCTAssertEqual(result, .failedStartingConnection)
                e.fulfill()
            }).addDisposableTo(disposeBag)

        waitForExpectations(timeout: 20, handler:  { error in
            if let error = error {
                XCTFail("first testConnectSuccess timed out: \(error)")
            }
        })
        stream.close()
        
    }
    
}
