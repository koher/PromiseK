import Foundation

func async<T>(value: T) -> Promise<T> {
	return Promise<T>({ resolve in
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
			resolve(Promise<T>(value))
		}
	})
}

func asyncFoo(value: Int) -> Promise<Int> {
	return async(value)
}

func asyncBar(value: Int) -> Promise<Int> {
	return async(value + value)
}

func asyncBaz(value: Int) -> Promise<Int> {
	return async(value * value)
}

func asyncQux(value: Int) -> Promise<Int?> {
	return async(value).map { arc4random() % 2 == 0 ? $0 : nil }
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

// asyncFoo, asyncBar, asyncBaz: Int -> Promise<Int>
let a: Promise<Int> = asyncFoo(2).flatMap { asyncBar($0) }.flatMap { asyncBaz($0) }
let b: Promise<Int> = asyncFoo(3).map { $0 * $0 }
let sum: Promise<Int> = a.flatMap { a0 in b.flatMap{ b0 in Promise<Int>(a0 + b0) } }

// asyncQux: Int -> Promise<Int?>
//   Returns Promise(nil) when it fails.
let mightFail: Promise<Int?> = asyncQux(5).flatMap { Promise<Int?>($0.map { $0 * $0 }) }
let howToCatch: Promise<Int> = asyncQux(7).flatMap { Promise<Int>($0 ?? 0) }

sum.wait()
println(a)
println(b)
println(sum)

mightFail.wait()
println(mightFail)

howToCatch.wait()
println(howToCatch)
