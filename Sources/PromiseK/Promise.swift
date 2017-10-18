import Foundation

public class Promise<Value> {
    private let lock = NSRecursiveLock()
    
    fileprivate var value: Value?
    private var handlers: [(Value) -> ()] = []
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public init(_ executor: (_ fulfill: @escaping (Value) -> ()) -> ()) {
        executor(fulfill)
    }
    
    private func fulfill(_ value: Value) {
        lock.lock()
        defer {
            lock.unlock()
        }
        if self.value == nil {
            self.value = value
            
            for handler in self.handlers {
                handler(value)
            }
            self.handlers.removeAll(keepingCapacity: false)
        }
    }
    
    public func map<T>(_ transform: @escaping (Value) -> T) -> Promise<T> {
        lock.lock()
        defer {
            lock.unlock()
        }

        if let value = self.value {
            return Promise<T>(transform(value))
        } else {
            return Promise<T> { fulfill in
                handlers.append { value in
                    fulfill(transform(value))
                }
            }
        }
    }
    
    public func flatMap<T>(_ transform: @escaping (Value) -> Promise<T>) -> Promise<T> {
        return Promise<T> { fulfill in self.get { transform($0).get { fulfill($0) } } }
    }
    
    public func get(_ handler: @escaping (Value) -> ()) {
        _ = map(handler)
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
