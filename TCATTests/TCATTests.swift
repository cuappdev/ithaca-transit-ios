//
//  TCATTests.swift
//  TCATTests
//
//  Created by Kevin Greer on 9/7/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import XCTest

class TCATTests: XCTestCase {
    
    var vc: TestRetainVC?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRetain() {
        print("* Test retain...")
        
        vc = TestRetainVC()
        
        TestManager.shared.fire("* Hello")
        TestManager.shared.fire("* Banana")
        
        vc = nil
        
        TestManager.shared.fire("* world")
        
        print("* Done.")
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
