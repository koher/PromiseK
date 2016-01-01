import XCTest
import PromiseK

class PromiseKTests: XCTestCase {
    func testPure() {
        let expectation = expectationWithDescription("")
        
        var result: Int = 0
        let promise: Promise<Int> = pure(2)
        promise.map {
            result = $0
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(3.0, handler: nil)

        XCTAssertEqual(2, result)
    }
    
    func testMap() {
        let expectation = expectationWithDescription("")

        asyncGet(3).map {
            XCTAssertEqual($0, 3)
            return $0 * $0
        }.map { (value: Int) in
            XCTAssertEqual(value, 9)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }
    
    func testFlatMap() {
        if true {
            let expectation = expectationWithDescription("")
            
            asyncGet(3).flatMap { (value: Int) -> Promise<()> in
                XCTAssertEqual(value, 3)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectationsWithTimeout(3.0, handler: nil)
        }
        
        if true {
            let expectation = expectationWithDescription("")
            
            asyncGet(3).flatMap { (value: Int) in
                XCTAssertEqual(value, 3)
                return asyncGet(value * value)
            }.flatMap { (value: Int) -> Promise<()> in
                XCTAssertEqual(value, 9)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectationsWithTimeout(3.0, handler: nil)
        }
    }
    
    func testFlatMapOperator() {
        if true {
            let expectation = expectationWithDescription("")
            
            asyncGet(3) >>- { (value: Int) -> Promise<()> in
                XCTAssertEqual(value, 3)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectationsWithTimeout(3.0, handler: nil)
        }
        
        if true {
            let expectation = expectationWithDescription("")
            
            asyncGet(3) >>- { (value: Int) in
                XCTAssertEqual(value, 3)
                return asyncGet(value * value)
            } >>- { (value: Int) -> Promise<()> in
                XCTAssertEqual(value, 9)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectationsWithTimeout(3.0, handler: nil)
        }
        
        if true {
            let expectation = expectationWithDescription("")
            
            asyncGetOrFail(3, false) >>- { (valueOrNil: Int?) -> Promise<Int?>? in
                valueOrNil.map { value in
                    XCTAssertEqual(value, 3)
                    return asyncGetOrFail(value * value, false)
                }
            } >>- { (valueOrNil: Int?) -> Promise<()> in
                if let value = valueOrNil {
                    XCTAssertEqual(value, 9)
                } else {
                    XCTFail()
                }
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectationsWithTimeout(3.0, handler: nil)
        }
        
        if true {
            let expectation = expectationWithDescription("")
            
            asyncGetOrFail(3, false) >>- { (valueOrNil: Int?) -> Promise<Int?>? in
                valueOrNil.map { value in
                    XCTAssertEqual(value, 3)
                    return asyncGetOrFail(value * value, true)
                }
            } >>- { (valueOrNil: Int?) -> Promise<()> in
                XCTAssertTrue(valueOrNil == nil)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectationsWithTimeout(3.0, handler: nil)
        }
        
        if true {
            let expectation = expectationWithDescription("")
            
            asyncGetOrFail(3, true) >>- { (valueOrNil: Int?) -> Promise<Int?>? in
                XCTAssertTrue(valueOrNil == nil)
                return valueOrNil.map { value in
                    XCTFail()
                    return asyncGetOrFail(value * value, true)
                }
            } >>- { (valueOrNil: Int?) -> Promise<()> in
                XCTAssertTrue(valueOrNil == nil)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectationsWithTimeout(3.0, handler: nil)
        }
    }
    
    func testFlatMapQOperator() {
        if true {
            let expectation = expectationWithDescription("")
            
            asyncGetOrFail(3, false) >>-? { value in
                XCTAssertEqual(value, 3)
                return asyncGetOrFail(value * value, false)
            } >>- { (valueOrNil: Int?) -> Promise<()> in
                if let value = valueOrNil {
                    XCTAssertEqual(value, 9)
                } else {
                    XCTFail()
                }
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectationsWithTimeout(3.0, handler: nil)
        }
        
        if true {
            let expectation = expectationWithDescription("")
            
            asyncGetOrFail(3, false) >>-? { value in
                XCTAssertEqual(value, 3)
                return asyncGetOrFail(value * value, true)
            } >>- { (valueOrNil: Int?) -> Promise<()> in
                XCTAssertTrue(valueOrNil == nil)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectationsWithTimeout(3.0, handler: nil)
        }
        
        if true {
            let expectation = expectationWithDescription("")
            
            asyncGetOrFail(3, true) >>-? { value in
                XCTFail()
                return asyncGetOrFail(value * value, true)
            } >>- { (valueOrNil: Int?) -> Promise<()> in
                XCTAssertTrue(valueOrNil == nil)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectationsWithTimeout(3.0, handler: nil)
        }
    }
    
    func testFlippedFlatMapOperator() {
        if true {
            let expectation = expectationWithDescription(""); // this ; is necessary
            
            { (value: Int) -> Promise<()> in
                XCTAssertEqual(value, 3)
                expectation.fulfill()
                return Promise<()>()
            } -<< asyncGet(3)
            
            waitForExpectationsWithTimeout(3.0, handler: nil)
        }
    }
    
    func testFlippedFlatMapQOperator() {
        if true {
            let expectation = expectationWithDescription(""); // this ; is necessary
            
            { (value: Int) -> Promise<()?> in
                XCTAssertEqual(value, 3)
                expectation.fulfill()
                return Promise<()?>(.Some())
            } -<<? asyncGetOrFail(3, false)
            
            waitForExpectationsWithTimeout(3.0, handler: nil)
        }
    }
    
    func testApplyOperator() {
        let expectation = expectationWithDescription("")
        
        (foo <^> asyncGet(2) <*> asyncGet(3)) >>- { (a: Int, b: Int) -> Promise<()> in
            XCTAssertEqual(a, 2)
            XCTAssertEqual(b, 3)
            expectation.fulfill()
            return Promise<()>()
        }
        
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }
    
    func testSynchronization() {
        let queue1 = dispatch_queue_create("foo", DISPATCH_QUEUE_SERIAL)
        let queue2 = dispatch_queue_create("bar", DISPATCH_QUEUE_SERIAL)

        for i in 1...100 { // cause simultaneous `resolve` and `reserve`
            let expectation = expectationWithDescription("\(i)")
            
            let promise = Promise<Int> { resolve in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))), queue1) {
                    resolve(pure(2))
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))), queue2) {
                let _: Promise<Int> = promise.flatMap {
                    expectation.fulfill()
                    return pure($0 * $0)
                }
            }
            
            waitForExpectationsWithTimeout(3.0, handler: nil)
        }
    }
}

func asyncGet(value: Int) -> Promise<Int> {
    return Promise { resolve in
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            resolve(Promise(value))
        }
    }
}

func asyncGetOrFail(value: Int, _ fails: Bool) -> Promise<Int?> {
    return fails ? Promise(nil) : asyncGet(value).map { $0 }
}

func foo(a: Int)(b: Int) -> (Int, Int) {
    return (a, b)
}
