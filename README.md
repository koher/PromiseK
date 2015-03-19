PromiseK
============================

_PromiseK_ provides the `Promise` class designed as a _Monad_ for Swift.

```swift
// `flatMap` is equivalent to `then` of JavaScript's `Promise`
let a: Promise<Int> = asyncGet(2).flatMap { asyncGet($0) }.flatMap { asyncGet($0) }
let b: Promise<Int> = asyncGet(3).map { $0 * $0 }
let sum: Promise<Int> = a.flatMap { a0 in b.flatMap{ b0 in Promise(a0 + b0) } }

// uses `Optional` for error handling
let mightFail: Promise<Int?> = asyncFailable(5).flatMap { Promise($0.map { $0 * $0 }) }
let howToCatch: Promise<Int> = asyncFailable(7).flatMap { Promise($0 ?? 0) }

// `>>-` operator is equivalent to `>>=` in Haskell
// can use `>>-` instead of `flatMap`
let a2: Promise<Int> = asyncGet(2) >>- { asyncGet($0) } >>- { asyncGet($0) }
// a failable operation chain with `>>-`
let failableChain: Promise<Int?> = asyncFailable(11) >>- { $0.map { asyncFailable($0) } }
```

How to Install
----------------------------

Put [PromiseK.swift](Project/PromiseK/PromiseK.swift) into your project.

License
----------------------------

[The MIT License](LICENSE)

References
----------------------------

1. [Promise - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
2. [JavaScript Promises: There and back again - HTML5 Rocks](http://www.html5rocks.com/en/tutorials/es6/promises/)
3. [A Fistful of Monads - Learn You a Haskell for Great Good!](http://learnyouahaskell.com/a-fistful-of-monads)
