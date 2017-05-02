import Foundation

public class Promise<Value> {
    private let lock = NSRecursiveLock()
    
    fileprivate var value: Value?
    private var handlers: [(Value) -> ()] = []
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public init(_ executor: (_ resolve: @escaping (Promise<Value>) -> ()) -> ()) {
        executor(resolve)
    }
    
    private func resolve(_ promise: Promise<Value>) {
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
    
    private func reserve(_ handler: @escaping (Value) -> ()) {
        lock.lock()
        if let value = self.value {
            handler(value)
        } else {
            handlers.append(handler)
        }
        lock.unlock()
    }
    
    public func map<T>(_ transform: @escaping (Value) -> T) -> Promise<T> {
        return flatMap { Promise<T>(transform($0)) }
    }
    
    public func flatMap<T>(_ transform: @escaping (Value) -> Promise<T>) -> Promise<T> {
        return Promise<T> { resolve in self.reserve { resolve(transform($0)) } }
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
