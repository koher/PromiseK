import Foundation

public class Promise<Value> {
    private var value: Value?
    private var handlers: [(Value) -> ()] = []
    private let lock = NSRecursiveLock()
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public init(_ executor: (_ fulfill: @escaping (Value) -> ()) -> ()) {
        executor { value in
            synchronized(with: self.lock) {
                precondition(self.value == nil, "`fulfill` cannot be called multiple times.")
                self.value = value
                self.handlers.forEach { $0(value) }
                self.handlers.removeAll(keepingCapacity: false)
            }
        }
    }
    
    public func get(_ handler: @escaping (Value) -> ()) {
        synchronized(with: lock) {
            if let value = self.value {
                handler(value)
            } else {
                handlers.append(handler)
            }
        }
    }
    
    public func map<T>(_ transform: @escaping (Value) -> T) -> Promise<T> {
        return Promise<T> { fulfill in get { fulfill(transform($0)) } }
    }
    
    public func flatMap<T>(_ transform: @escaping (Value) -> Promise<T>) -> Promise<T> {
        return Promise<T> { fulfill in get { transform($0).get { fulfill($0) } } }
    }
}

extension Promise : CustomStringConvertible {
    public var description: String {
        if let value = self.value {
            return "Promise(\(value))"
        } else {
            return "Promise(\(Value.self))"
        }
    }
}

private func synchronized(with lock: NSRecursiveLock, _ operation: () -> ()) {
    lock.lock()
    defer { lock.unlock() }
    operation()
}
