public class Promise<T> {
    private var value: T?
    private var handlers: [T -> ()]
    
    public init(_ value: T) {
        self.value = value
        handlers = []
    }
    
    public init(_ executor: (resolve: Promise<T> -> ()) -> ()) {
        handlers = []
        executor(resolve: resolve)
    }
    
    private func resolve(promise: Promise<T>) {
        promise.`defer` {
            if self.value != nil {
                return
            }
            self.value = $0
            
            for handler in self.handlers {
                handler($0)
            }
            self.handlers.removeAll(keepCapacity: false)
        }
    }
    
    private func `defer`(handler: T -> ()) {
        if let value = self.value {
            handler(value)
        } else {
            handlers.append(handler)
        }
    }
    
    public func map<U>(f: T -> U) -> Promise<U> {
        return flatMap { Promise<U>(f($0)) }
    }
    
    public func flatMap<U>(f: T -> Promise<U>) -> Promise<U> {
        return Promise<U>({ resolve in self.`defer` { resolve(f($0)) } })
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

public func flatten<T>(x: Promise<Promise<T>>) -> Promise<T> {
    return x.flatMap { $0 }
}

public func >>-<T, U>(lhs: Promise<T>, rhs: T -> Promise<U>) -> Promise<U> {
    return lhs.flatMap(rhs)
}

public func >>-<T, U>(lhs: Promise<T?>, rhs: T? -> Promise<U?>?) -> Promise<U?> {
    return lhs.flatMap { rhs($0) ?? Promise(nil) }
}

public func <^><T, U>(lhs: T -> U, rhs: Promise<T>) -> Promise<U> {
    return rhs.map(lhs)
}

public func <*><T, U>(lhs: Promise<T -> U>, rhs: Promise<T>) -> Promise<U> {
    return rhs.apply(lhs)
}