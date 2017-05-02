PromiseK
============================

_PromiseK_ provides a simple monadic `Promise` type for Swift.

```swift
// `map` and `flatMap` are equivalent to `then` of JavaScript's `Promise`
let a: Promise<Int> = asyncGet(2).flatMap { asyncGet($0) }.flatMap { asyncGet($0) }
let b: Promise<Int> = asyncGet(3).map { $0 * $0 }
let sum: Promise<Int> = a.flatMap { a0 in b.flatMap { b0 in Promise(a0 + b0) } }
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
