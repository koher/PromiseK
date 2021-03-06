extension Promise {
    public func map<T>(_ transform: @escaping (Value) throws -> T) -> Promise<() throws -> T> {
        return map { value in
            do {
                let transformed = try transform(value)
                return { transformed }
            } catch let error {
                return { throw error }
            }
        }
    }
    
    private func _flatMap<T>(_ transform: @escaping (Value) -> Promise<T>) -> Promise<T> {
        return flatMap(transform)
    }
    
    public func flatMap<T>(_ transform: @escaping (Value) -> Promise<() throws -> T>) -> Promise<() throws -> T> {
        return _flatMap(transform)
    }
    
    public func flatMap<T>(_ transform: @escaping (Value) throws -> Promise<T>) -> Promise<() throws -> T> {
        return _flatMap { value in
            do {
                return try transform(value).map { value in { value } }
            } catch let error {
                return Promise<() throws -> T>({ throw error })
            }
        }
    }
    
    public func flatMap<T>(_ transform: @escaping (Value) throws -> Promise<() throws -> T>) -> Promise<() throws -> T> {
        return _flatMap { value in
            do {
                return try transform(value)
            } catch let error {
                return Promise<() throws -> T>({ throw error })
            }
        }
    }
}
