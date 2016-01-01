PromiseK
============================

_PromiseK_ provides the `Promise` class designed as a _Monad_ for Swift.

```swift
// `flatMap` is equivalent to `then` of JavaScript's `Promise`
let a: Promise<Int> = asyncGet(2).flatMap { asyncGet($0) }.flatMap { asyncGet($0) }
let b: Promise<Int> = asyncGet(3).map { $0 * $0 }
let sum: Promise<Int> = a.flatMap { a0 in b.flatMap { b0 in Promise(a0 + b0) } }

// uses `Optional` for error handling
let mightFail: Promise<Int?> = asyncFailable(5).flatMap { Promise($0.map { $0 * $0 }) }
let howToCatch: Promise<Int> = asyncFailable(7).flatMap { Promise($0 ?? 0) }

// `>>-` operator is equivalent to `>>=` in Haskell
// can use `>>-` instead of `flatMap`
let a2: Promise<Int> = asyncGet(2) >>- { asyncGet($0) } >>- { asyncGet($0) }
// a failable operation chain with `>>-`
let failableChain: Promise<Int?> = asyncFailable(11) >>- { $0.map { asyncFailable($0) } }
// also `>>-?` operator is available
let failableChain2: Promise<Int?> = asyncFailable(11) >>-? { asyncFailable($0) }
```

Installation
----------------------------

### Carthage

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

[_Carthage_](https://github.com/Carthage/Carthage) is available to install _PromiseK_. Add it to your _Cartfile_:

```
github "koher/PromiseK" ~> 2.0
```

### Manually

#### Embedded Framework

For iOS 8 or later,

1. Put [PromiseK.xcodeproj](PromiseK.xcodeproj) into your project in Xcode.
2. Click the project icon and select the "General" tab.
3. Add PromiseK.framework to "Embedded Binaries".
4. `import PromiseK` in your swift files.

#### Source

For iOS 7, put all swift files in the [Source](Source) directory into your project.

License
----------------------------

[The MIT License](LICENSE)

References
----------------------------

1. [Promise - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
2. [JavaScript Promises: There and back again - HTML5 Rocks](http://www.html5rocks.com/en/tutorials/es6/promises/)
3. [A Fistful of Monads - Learn You a Haskell for Great Good!](http://learnyouahaskell.com/a-fistful-of-monads)
