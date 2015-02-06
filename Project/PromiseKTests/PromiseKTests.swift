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
		
		let a: Promise<Int> = Promise<Int>(2)
		let b: Promise<Int> = Promise<Int>(3)
		let sum: Promise<Int> = a.flatMap { a0 in b.flatMap{ b0 in Promise<Int>(a0 + b0) } }
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
	return Promise<Int>({ resolve in
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
			resolve(Promise<Int>(value))
		}
	})
}

