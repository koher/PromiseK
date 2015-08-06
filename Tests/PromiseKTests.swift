import XCTest
import PromiseK

class PromiseKTests: XCTestCase {
    func testMap() {
        var reaches: Bool
        
        reaches = false
        asyncGet(3).map {
            reaches = true
            XCTAssertEqual($0, 3)
            return $0 * $0
        }.map { (value: Int) in
            XCTAssertEqual(value, 9)
        }.wait()
        XCTAssertTrue(reaches)
    }
    
    func testFlatMap() {
        var reaches: Bool
        
        reaches = false
        asyncGet(3).flatMap { (value: Int) -> Promise<()> in
            reaches = true
            XCTAssertEqual(value, 3)
            return Promise<()>()
        }.wait()
        XCTAssertTrue(reaches)
        
        reaches = false
        asyncGet(3).flatMap { (value: Int) in
            XCTAssertEqual(value, 3)
            return asyncGet(value * value)
        }.flatMap { (value: Int) -> Promise<()> in
            reaches = true
            XCTAssertEqual(value, 9)
            return Promise<()>()
        }.wait()
        XCTAssertTrue(reaches)
    }
    
    func testFlatMapOperator() {
        var reaches: Bool
        
        reaches = false
        (asyncGet(3) >>- { (value: Int) -> Promise<()> in
            reaches = true
            XCTAssertEqual(value, 3)
            return Promise<()>()
        }).wait()
        XCTAssertTrue(reaches)
        
        reaches = false
        (asyncGet(3) >>- { (value: Int) in
            XCTAssertEqual(value, 3)
            return asyncGet(value * value)
        } >>- { (value: Int) -> Promise<()> in
                reaches = true
                XCTAssertEqual(value, 9)
                return Promise<()>()
        }).wait()
        XCTAssertTrue(reaches)
        
        reaches = false
        (asyncGetOrFail(3, false) >>- { (valueOrNil: Int?) -> Promise<Int?>? in
            return valueOrNil.map { value in
                XCTAssertEqual(value, 3)
                return asyncGetOrFail(value * value, false)
            }
        } >>- { (valueOrNil: Int?) -> Promise<()> in
            if let value = valueOrNil {
                XCTAssertEqual(value, 9)
                reaches = true
            } else {
                XCTFail()
            }
            return Promise<()>()
        }).wait()
        XCTAssertTrue(reaches)
        
        reaches = false
        (asyncGetOrFail(3, false) >>- { (valueOrNil: Int?) -> Promise<Int?>? in
            return valueOrNil.map { value in
                XCTAssertEqual(value, 3)
                return asyncGetOrFail(value * value, true)
            }
        } >>- { (valueOrNil: Int?) -> Promise<()> in
            XCTAssertTrue(valueOrNil == nil)
            reaches = true
            return Promise<()>()
        }).wait()
        XCTAssertTrue(reaches)
        
        reaches = false
        (asyncGetOrFail(3, true) >>- { (valueOrNil: Int?) -> Promise<Int?>? in
            XCTAssertTrue(valueOrNil == nil)
            return valueOrNil.map { value in
                XCTFail()
                return asyncGetOrFail(value * value, true)
            }
        } >>- { (valueOrNil: Int?) -> Promise<()> in
            XCTAssertTrue(valueOrNil == nil)
            reaches = true
            return Promise<()>()
        }).wait()
        XCTAssertTrue(reaches)
    }
}

extension Promise {
    func wait() {
        var finished = false
        self.flatMap { (value: T) -> Promise<()> in
            finished = true
            return Promise<()>()
        }
        while (!finished){
            NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.1))
        }
    }
}

func asyncGet(value: Int) -> Promise<Int> {
    return Promise({ resolve in
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            resolve(Promise(value))
        }
    })
}

func asyncGetOrFail(value: Int, _ fails: Bool) -> Promise<Int?> {
    return fails ? Promise(nil) : asyncGet(value).map { $0 }
}

