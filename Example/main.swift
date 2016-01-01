import Foundation

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

func async<T>(value: T) -> Promise<T> {
    return Promise<T> { resolve in
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            resolve(Promise(value))
        }
    }
}

func asyncGet(value: Int) -> Promise<Int> {
    return async(value)
}

func asyncFailable(value: Int) -> Promise<Int?> {
    return async(value).map { arc4random() % 2 == 0 ? $0 : nil }
}

// `flatMap` is equivalent to `then` of JavaScript's `Promise`
let a: Promise<Int> = asyncGet(2).flatMap { asyncGet($0) }.flatMap { asyncGet($0) }
let b: Promise<Int> = asyncGet(3).map { $0 * $0 }
let sum: Promise<Int> = a.flatMap { a0 in b.flatMap{ b0 in Promise(a0 + b0) } }

// uses `Optional` for error handling
let mightFail: Promise<Int?> = asyncFailable(5).flatMap { Promise($0.map { $0 * $0 }) }
let howToCatch: Promise<Int> = asyncFailable(7).flatMap { Promise($0 ?? 0) }

// `>>-` operator is equivalent to `>>=` in Haskell
// can use `>>-` instead of `flatMap`
let a2: Promise<Int> = asyncGet(2) >>- { asyncGet($0) } >>- { asyncGet($0) }
// a failable operation chain with `>>-`
let failableChain: Promise<Int?> = asyncFailable(11) >>- { $0.map { asyncFailable($0) } }
// also `>>-?` operator is available
let failableChain2: Promise<Int?> = asyncFailable(11) >>-? { asyncFailable($0) }

sum.wait()
print(a)
print(b)
print(sum)

mightFail.wait()
print(mightFail)

howToCatch.wait()
print(howToCatch)

a2.wait()
print(a2)

failableChain.wait()
print(failableChain)

failableChain2.wait()
print(failableChain2)
