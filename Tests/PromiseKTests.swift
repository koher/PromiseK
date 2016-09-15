import XCTest
import PromiseK

class PromiseKTests: XCTestCase {
    func testPure() {
        let expectation = self.expectation(description: "")
        
        var result: Int = 0
        let promise: Promise<Int> = pure(2)
        promise.map {
            result = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0, handler: nil)

        XCTAssertEqual(2, result)
    }
    
    func testMap() {
        let expectation = self.expectation(description: "")

        asyncGet(3).map {
            XCTAssertEqual($0, 3)
            return $0 * $0
        }.map { (value: Int) in
            XCTAssertEqual(value, 9)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFlatMap() {
        do {
            let expectation = self.expectation(description: "")
            
            asyncGet(3).flatMap { (value: Int) -> Promise<()> in
                XCTAssertEqual(value, 3)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
        
        do {
            let expectation = self.expectation(description: "")
            
            asyncGet(3).flatMap { (value: Int) in
                XCTAssertEqual(value, 3)
                return asyncGet(value * value)
            }.flatMap { (value: Int) -> Promise<()> in
                XCTAssertEqual(value, 9)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
    }
    
    func testFlatMapOperator() {
        do {
            let expectation = self.expectation(description: "")
            
            asyncGet(3) >>- { (value: Int) -> Promise<()> in
                XCTAssertEqual(value, 3)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
        
        do {
            let expectation = self.expectation(description: "")
            
            asyncGet(3) >>- { (value: Int) in
                XCTAssertEqual(value, 3)
                return asyncGet(value * value)
            } >>- { (value: Int) -> Promise<()> in
                XCTAssertEqual(value, 9)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
        
        do {
            let expectation = self.expectation(description: "")
            
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
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
        
        do {
            let expectation = self.expectation(description: "")
            
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
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
        
        do {
            let expectation = self.expectation(description: "")
            
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
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
    }
    
    func testFlatMapQOperator() {
        do {
            let expectation = self.expectation(description: "")
            
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
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
        
        do {
            let expectation = self.expectation(description: "")
            
            asyncGetOrFail(3, false) >>-? { value in
                XCTAssertEqual(value, 3)
                return asyncGetOrFail(value * value, true)
            } >>- { (valueOrNil: Int?) -> Promise<()> in
                XCTAssertTrue(valueOrNil == nil)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
        
        do {
            let expectation = self.expectation(description: "")
            
            asyncGetOrFail(3, true) >>-? { value in
                XCTFail()
                return asyncGetOrFail(value * value, true)
            } >>- { (valueOrNil: Int?) -> Promise<()> in
                XCTAssertTrue(valueOrNil == nil)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
    }
    
    func testFlippedFlatMapOperator() {
        do {
            let expectation = self.expectation(description: ""); // this ; is necessary
            
            { (value: Int) -> Promise<()> in
                XCTAssertEqual(value, 3)
                expectation.fulfill()
                return Promise<()>()
            } -<< asyncGet(3)
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
    }
    
    func testFlippedFlatMapQOperator() {
        do {
            let expectation = self.expectation(description: ""); // this ; is necessary
            
            { (value: Int) -> Promise<()?> in
                XCTAssertEqual(value, 3)
                expectation.fulfill()
                return Promise<()?>(.some())
            } -<<? asyncGetOrFail(3, false)
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
    }
    
    func testApplyOperator() {
        let expectation = self.expectation(description: "")
        
        (foo <^> asyncGet(2) <*> asyncGet(3)) >>- { (a: Int, b: Int) -> Promise<()> in
            XCTAssertEqual(a, 2)
            XCTAssertEqual(b, 3)
            expectation.fulfill()
            return Promise<()>()
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testSynchronization() {
        let queue1 = DispatchQueue(label: "foo", attributes: [])
        let queue2 = DispatchQueue(label: "bar", attributes: [])

        for i in 1...100 { // cause simultaneous `resolve` and `reserve`
            let expectation = self.expectation(description: "\(i)")
            
            let promise = Promise<Int> { resolve in
                queue1.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                    resolve(pure(2))
                }
            }
            
            queue2.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                let _: Promise<Int> = promise.flatMap {
                    expectation.fulfill()
                    return pure($0 * $0)
                }
            }
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
    }
}

func asyncGet(_ value: Int) -> Promise<Int> {
    return Promise { resolve in
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            resolve(Promise(value))
        }
    }
}

func asyncGetOrFail(_ value: Int, _ fails: Bool) -> Promise<Int?> {
    return fails ? Promise(nil) : asyncGet(value).map { $0 }
}

func foo(_ a: Int, _ b: Int) -> (Int, Int) {
    return (a, b)
}
