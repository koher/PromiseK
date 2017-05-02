import Foundation

public class Promise<T> {
    fileprivate let lock = NSRecursiveLock()
    
    fileprivate var value: T?
    fileprivate var handlers: [(T) -> ()] = []
    
    public init(_ value: T) {
        self.value = value
    }
    
    public init(_ executor: (_ resolve: @escaping (Promise<T>) -> ()) -> ()) {
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
    
    public func map<U>(_ f: @escaping (T) -> U) -> Promise<U> {
        return flatMap { Promise<U>(f($0)) }
    }
    
    public func flatMap<U>(_ f: @escaping (T) -> Promise<U>) -> Promise<U> {
        return Promise<U> { resolve in self.reserve { resolve(f($0)) } }
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
