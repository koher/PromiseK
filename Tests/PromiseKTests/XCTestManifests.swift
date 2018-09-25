import XCTest

extension PromiseKTests {
    static let __allTests = [
        ("testDescription", testDescription),
        ("testFailableFlatMap", testFailableFlatMap),
        ("testFailableMap", testFailableMap),
        ("testFlatMap", testFlatMap),
        ("testGet", testGet),
        ("testKeepingFulfill", testKeepingFulfill),
        ("testMap", testMap),
        ("testSample", testSample),
        ("testSynchronization", testSynchronization),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PromiseKTests.__allTests),
    ]
}
#endif
