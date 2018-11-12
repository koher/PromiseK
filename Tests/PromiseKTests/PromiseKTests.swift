import XCTest
import PromiseK

class PromiseKTests: XCTestCase {
    func testMap() {
        let squared = asyncGet(3).map {
            $0 * $0
        }
        
        XCTAssertEqual(squared.sync(), 9)
    }
    
    func testFlatMap() {
        do {
            let a = asyncGet(2)
            let b = asyncGet(3)
            let sum = a.flatMap { a in
                b.map { b in
                    a + b
                }
            }
            
            XCTAssertEqual(sum.sync(), 5)
        }
        
        do {
            let sum = asyncGet(2).flatMap { a in
                asyncGet(3).map { b in
                    a + b
                }
            }
            
            XCTAssertEqual(sum.sync(), 5)
        }
    }
    
    func testGet() {
        let expectation = self.expectation(description: "testGet")
        
        let value = asyncGet(42)
        var obtained: Int? = nil
        value.get {
            obtained = $0
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertEqual(obtained, .some(42))
    }
    
    func testDescription() {
        XCTAssertEqual(Promise(42).description, "Promise(42)")
        XCTAssertEqual(Promise<Int> { _ in }.description, "Promise(Int)")
    }
    
    func testFailableMap() {
        do {
            let squared = asyncGetOrFail(3, false).map {
                try $0() * $0()
            }
            
            XCTAssertEqual(try squared.sync()(), 9)
        }
        
        do {
            let squared = asyncGetOrFail(3, true).map {
                try $0() * $0()
            }
            
            _ = try squared.sync()()
            XCTFail()
        } catch let error as FooError {
            XCTAssertEqual(error.value, 3)
        } catch _ {
            XCTFail()
        }
    }
    
    func testFailableFlatMap() {
        do {
            let a = asyncGetOrFail(2, false)
            let b = asyncGetOrFail(3, false)
            let sum = a.flatMap { a in
                b.map { b in
                    try a() + b()
                }
            }
            
            XCTAssertEqual(try sum.sync()(), 5)
        }

        do {
            let a = asyncGetOrFail(2, true)
            let b = asyncGetOrFail(3, false)
            let sum = a.flatMap { a in
                b.map { b in
                    try a() + b()
                }
            }

            _ = try sum.sync()()
            XCTFail()
        } catch let error as FooError {
            XCTAssertEqual(error.value, 2)
        } catch _ {
            XCTFail()
        }
        
        do {
            let a = asyncGetOrFail(2, false)
            let b = asyncGetOrFail(3, true)
            let sum = a.flatMap { a in
                b.map { b in
                    try a() + b()
                }
            }
            
            _ = try sum.sync()()
            XCTFail()
        } catch let error as FooError {
            XCTAssertEqual(error.value, 3)
        } catch _ {
            XCTFail()
        }

        do {
            let a = asyncGetOrFail(2, true)
            let b = asyncGetOrFail(3, true)
            let sum = a.flatMap { a in
                b.map { b in
                    try a() + b()
                }
            }
            
            _ = try sum.sync()()
            XCTFail()
        } catch let error as FooError {
            XCTAssertEqual(error.value, 2)
        } catch _ {
            XCTFail()
        }
        
        do {
            let sum = asyncGetOrFail(2, false).flatMap { getA throws -> Promise<Int> in
                let a = try getA()
                return asyncGet(3).map { b in
                    a + b
                }
            }
            
            XCTAssertEqual(try sum.sync()(), 5)
        }
        
        do {
            let sum = asyncGetOrFail(2, true).flatMap { getA throws -> Promise<Int> in
                let a = try getA()
                return asyncGet(3).map { b in
                    a + b
                }
            }
            
            _ = try sum.sync()()
            XCTFail()
        } catch let error as FooError {
            XCTAssertEqual(error.value, 2)
        } catch _ {
            XCTFail()
        }
    }
    
    func testSynchronization() {
        let queue1 = DispatchQueue(label: "foo", attributes: [])
        let queue2 = DispatchQueue(label: "bar", attributes: [])

        for i in 1...100 { // cause simultaneous `fulfill` and `map`
            let expectation = self.expectation(description: "\(i)")
            
            let promise = Promise<Int> { fulfill in
                queue1.asyncAfter(deadline: .now() + 0.01) {
                    fulfill(2)
                }
            }
            
            queue2.asyncAfter(deadline: .now() + 0.01) {
                let _: Promise<Int> = promise.flatMap {
                    expectation.fulfill()
                    return Promise($0 * $0)
                }
            }
            
            waitForExpectations(timeout: 3.0, handler: nil)
        }
    }
    
    func testKeepingFulfill() {
        do {
            var fulfill: ((Int) -> ())!
            let a = Promise<Int> {
                fulfill = $0
            }
            fulfill(42)
            XCTAssertEqual(a.sync(), 42)
        }
        
        do {
            var fulfill: ((@escaping () throws -> Int) -> ())!
            let a = Promise<() throws -> Int> {
                fulfill = $0
            }
            fulfill { 42 }
            XCTAssertEqual(try! a.sync()(), 42)
        }
        
        do {
            let queue = DispatchQueue(label: "foo", attributes: [])

            var fulfill: ((@escaping () throws -> Int) -> ())!
            let a = Promise<() throws -> Int> {
                fulfill = $0
            }
            
            let expectation = self.expectation(description: "testKeepingFulfill")
            
            queue.asyncAfter(deadline: .now() + 0.01) {
                fulfill { 42 }
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 3.0, handler: nil)
            
            XCTAssertEqual(try! a.sync()(), 42)
        }
    }
    
    func testSample() {
        do {
            // `flatMap` is equivalent to `then` of JavaScript's `Promise`
            let a: Promise<Int> = asyncGet(2)
            let b: Promise<Int> = asyncGet(3).map { $0 * $0 } // Promise(9)
            let sum: Promise<Int> = a.flatMap { a in b.map { b in a + b } }
            
            sum.wait()
            print(a)
            print(b)
            print(sum)
        }

        do {
            // Collaborates with `throws` for error handling
            let a: Promise<() throws -> Int> = asyncFailable(2)
            let b: Promise<() throws -> Int> = asyncFailable(3).map { try $0() * $0() }
            let sum: Promise<() throws -> Int> = a.flatMap { a in b.map { b in try a() * b() } }
            
            sum.wait()
            print(a)
            print(b)
            print(sum)
        }

        do {
            // Recovery from errors
            let recovered: Promise<Int> = asyncFailable(42).map { value in
                do {
                    return try value()
                } catch _ {
                    return -1
                }
            }
            
            recovered.wait()
            print(recovered)
        }
    }
}

func async<T>(_ value: T) -> Promise<T> {
    return Promise<T> { fulfill in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            fulfill(value)
        }
    }
}

func asyncGet(_ value: Int) -> Promise<Int> {
    return async(value)
}

func asyncGetOrFail(_ value: Int, _ fails: Bool) -> Promise<() throws -> Int> {
    return asyncGet(value).map {
        if fails {
            throw FooError(value: value)
        }
        return $0
    }
}

func asyncFailable(_ value: Int) -> Promise<() throws -> Int> {
    return asyncGetOrFail(value, Bool.random())
}

struct FooError: Error {
    var value: Int
}

extension Promise {
    func wait() {
        var finished = false
        _ = self.flatMap { _ -> Promise<()> in
            finished = true
            return Promise<()>(())
        }
        while !finished {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
    }
    
    func sync() -> Value {
        wait()
        var value: Value? = nil
        get {
            value = $0
        }
        return value!
    }
}
