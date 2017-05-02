PromiseK
============================

_PromiseK_ provides a simple monadic `Promise` type for Swift.

```swift
// `flatMap` is equivalent to `then` of JavaScript's `Promise`
let a: Promise<Int> = asyncGet(2)
let b: Promise<Int> = asyncGet(3).map { $0 * $0 } // Promise(9)
let sum: Promise<Int> = a.flatMap { a in b.flatMap{ b in Promise(a + b) } }
```

`Promise` can collaborate with `throws` for failable asynchronous operations.

```swift
// Collaborates with `throws` for error handling
let a: Promise<() throws -> Int> = asyncFailable(2)
let b: Promise<() throws -> Int> = asyncFailable(3).map { try $0() * $0() }
let sum: Promise<() throws -> Int> = a.flatMap { a in b.map { b in try a() * b() } }
```

It is also possible to recover from errors.

```swift
// Recovery from errors
let recovered: Promise<Int> = asyncFailable(42).map { value in
    do {
        return try value()
    } catch _ {
        return -1
    }
}
```

Installation
----------------------------

By Swift Package Manager.

```swift
.Package(
    url: "https://github.com/koher/PromiseK.git",
    majorVersion: 3
)
```

License
----------------------------

[The MIT License](LICENSE)

References
----------------------------

1. [Promise - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
2. [JavaScript Promises: There and back again - HTML5 Rocks](http://www.html5rocks.com/en/tutorials/es6/promises/)
3. [A Fistful of Monads - Learn You a Haskell for Great Good!](http://learnyouahaskell.com/a-fistful-of-monads)
