import Foundation

open class Promise<T> {
    fileprivate let lock = NSRecursiveLock()
    
    fileprivate var value: T?
    fileprivate var handlers: [(T) -> ()] = []
    
    public init(_ value: T) {
        self.value = value
    }
    
    public init(_ executor: (_ resolve: (Promise<T>) -> ()) -> ()) {
        executor(resolve)
    }
    
    fileprivate func resolve(_ promise: Promise<T>) {
        promise.reserve {
            self.lock.lock()
            if self.value == nil {
                self.value = $0
                
                for handler in self.handlers {
                    handler($0)
                }
                self.handlers.removeAll(keepingCapacity: false)
            }
            self.lock.unlock()
        }
    }
    
    fileprivate func reserve(_ handler: @escaping (T) -> ()) {
        lock.lock()
        if let value = self.value {
            handler(value)
        } else {
            handlers.append(handler)
        }
        lock.unlock()
    }
    
    open func map<U>(_ f: @escaping (T) -> U) -> Promise<U> {
        return flatMap { Promise<U>(f($0)) }
    }
    
    open func flatMap<U>(_ f: @escaping (T) -> Promise<U>) -> Promise<U> {
        return Promise<U> { resolve in self.reserve { resolve(f($0)) } }
    }
    
    open func apply<U>(_ f: Promise<(T) -> U>) -> Promise<U> {
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

public func pure<T>(_ x: T) -> Promise<T> {
    return Promise(x)
}

public func flatten<T>(_ x: Promise<Promise<T>>) -> Promise<T> {
    return x.flatMap { $0 }
}

public func >>-<T, U>(lhs: Promise<T>, rhs: @escaping (T) -> Promise<U>) -> Promise<U> {
    return lhs.flatMap(rhs)
}

public func >>-?<T, U>(lhs: Promise<T?>, rhs: @escaping (T) -> Promise<U?>) -> Promise<U?> {
    return lhs.flatMap { $0.map(rhs) ?? Promise(nil) }
}

public func >>-<T, U>(lhs: Promise<T?>, rhs: @escaping (T?) -> Promise<U?>?) -> Promise<U?> {
    return lhs.flatMap { rhs($0) ?? Promise(nil) }
}

public func -<<<T, U>(lhs: @escaping (T) -> Promise<U>, rhs: Promise<T>) -> Promise<U> {
    return rhs.flatMap(lhs)
}

public func -<<?<T, U>(lhs: @escaping (T) -> Promise<U?>, rhs: Promise<T?>) -> Promise<U?> {
    return rhs >>-? lhs
}

public func <^><T, U>(lhs: @escaping (T) -> U, rhs: Promise<T>) -> Promise<U> {
    return rhs.map(lhs)
}

public func <*><T, U>(lhs: Promise<(T) -> U>, rhs: Promise<T>) -> Promise<U> {
    return rhs.apply(lhs)
}
