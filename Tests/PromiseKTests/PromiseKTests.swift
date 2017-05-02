import XCTest
@testable import PromiseK

class PromiseKTests: XCTestCase {
    func testMap() {
        let expectation = self.expectation(description: "")

        _ = asyncGet(3).map {
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
            
            _ = asyncGet(3).flatMap { (value: Int) -> Promise<()> in
                XCTAssertEqual(value, 3)
                expectation.fulfill()
                return Promise<()>()
            }
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
        
        do {
            let expectation = self.expectation(description: "")
            
            _ = asyncGet(3).flatMap { (value: Int) in
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
    
    func testSynchronization() {
        let queue1 = DispatchQueue(label: "foo", attributes: [])
        let queue2 = DispatchQueue(label: "bar", attributes: [])

        for i in 1...100 { // cause simultaneous `resolve` and `reserve`
            let expectation = self.expectation(description: "\(i)")
            
            let promise = Promise<Int> { resolve in
                queue1.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                    resolve(Promise(2))
                }
            }
            
            queue2.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                let _: Promise<Int> = promise.flatMap {
                    expectation.fulfill()
                    return Promise($0 * $0)
                }
            }
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
    }
    
    func testSample() {
        // `flatMap` is equivalent to `then` of JavaScript's `Promise`
        let a: Promise<Int> = asyncGet(2).flatMap { asyncGet($0) }.flatMap { asyncGet($0) }
        let b: Promise<Int> = asyncGet(3).map { $0 * $0 }
        let sum: Promise<Int> = a.flatMap { a0 in b.flatMap{ b0 in Promise(a0 + b0) } }
        
        // uses `Optional` for error handling
        let mightFail: Promise<Int?> = asyncFailable(5).flatMap { Promise($0.map { $0 * $0 }) }
        let howToCatch: Promise<Int> = asyncFailable(7).flatMap { Promise($0 ?? 0) }
        
        sum.wait()
        print(a)
        print(b)
        print(sum)
        
        mightFail.wait()
        print(mightFail)
        
        howToCatch.wait()
        print(howToCatch)
    }
}

func async<T>(_ value: T) -> Promise<T> {
    return Promise<T> { resolve in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            resolve(Promise(value))
        }
    }
}

func asyncGet(_ value: Int) -> Promise<Int> {
    return async(value)
}

func asyncGetOrFail(_ value: Int, _ fails: Bool) -> Promise<Int?> {
    return fails ? Promise(nil) : asyncGet(value).map { $0 }
}

func asyncFailable(_ value: Int) -> Promise<Int?> {
    return async(value).map { arc4random() % 2 == 0 ? $0 : nil }
}

func foo(_ a: Int, _ b: Int) -> (Int, Int) {
    return (a, b)
}

func curry<A, B, Z>(_ f: @escaping (A, B) -> Z) -> (A) -> (B) -> Z {
    return { a in { b in f(a, b) } }
}

extension Promise {
    func wait() {
        var finished = false
        _ = self.flatMap { (value: Value) -> Promise<()> in
            finished = true
            return Promise<()>()
        }
        while (!finished){
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
    }
}
