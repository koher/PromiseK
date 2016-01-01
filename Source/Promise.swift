import Foundation

public class Promise<T> {
    private let lock = NSObject()
    
    private var value: T?
    private var handlers: [T -> ()] = []
    
    public init(_ value: T) {
        self.value = value
    }
    
    public init(_ executor: (resolve: Promise<T> -> ()) -> ()) {
        executor(resolve: resolve)
    }
    
    private func resolve(promise: Promise<T>) {
        promise.reserve {
            objc_sync_enter(self.lock)
            if self.value == nil {
                self.value = $0
                
                for handler in self.handlers {
                    handler($0)
                }
                self.handlers.removeAll(keepCapacity: false)
            }
            objc_sync_exit(self.lock)
        }
    }
    
    private func reserve(handler: T -> ()) {
        objc_sync_enter(lock)
        if let value = self.value {
            handler(value)
        } else {
            handlers.append(handler)
        }
        objc_sync_exit(lock)
    }
    
    public func map<U>(f: T -> U) -> Promise<U> {
        return flatMap { Promise<U>(f($0)) }
    }
    
    public func flatMap<U>(f: T -> Promise<U>) -> Promise<U> {
        return Promise<U> { resolve in self.reserve { resolve(f($0)) } }
    }
    
    public func apply<U>(f: Promise<T -> U>) -> Promise<U> {
        return f.flatMap { self.map($0) }
    }
}

extension Promise : CustomStringConvertible {
    public var description: String {
        if let value = self.value {
            return "Promise(\(value))"
        } else {
            return "Promise"
        }
    }
}

public func pure<T>(x: T) -> Promise<T> {
    return Promise(x)
}

public func flatten<T>(x: Promise<Promise<T>>) -> Promise<T> {
    return x.flatMap { $0 }
}

public func >>-<T, U>(lhs: Promise<T>, rhs: T -> Promise<U>) -> Promise<U> {
    return lhs.flatMap(rhs)
}

public func >>-?<T, U>(lhs: Promise<T?>, rhs: T -> Promise<U?>) -> Promise<U?> {
    return lhs.flatMap { x in
        switch x {
        case .None:
            return pure(.None)
        case let .Some(x):
            return rhs(x)
        }
    }
}

public func >>-<T, U>(lhs: Promise<T?>, rhs: T? -> Promise<U?>?) -> Promise<U?> {
    return lhs.flatMap { rhs($0) ?? Promise(nil) }
}

public func -<<<T, U>(lhs: T -> Promise<U>, rhs: Promise<T>) -> Promise<U> {
    return rhs.flatMap(lhs)
}

public func -<<?<T, U>(lhs: T -> Promise<U?>, rhs: Promise<T?>) -> Promise<U?> {
    return rhs >>-? lhs
}

public func <^><T, U>(lhs: T -> U, rhs: Promise<T>) -> Promise<U> {
    return rhs.map(lhs)
}

public func <*><T, U>(lhs: Promise<T -> U>, rhs: Promise<T>) -> Promise<U> {
    return rhs.apply(lhs)
}