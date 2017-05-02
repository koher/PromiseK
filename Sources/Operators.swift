precedencegroup PromiseKMonadicPrecedenceRight {
    associativity: right
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

precedencegroup PromiseKMonadicPrecedenceLeft {
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

precedencegroup PromiseKApplicativePrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: NilCoalescingPrecedence
}

infix operator >>- : PromiseKMonadicPrecedenceLeft
infix operator -<< : PromiseKMonadicPrecedenceRight

infix operator <^> : PromiseKApplicativePrecedence
infix operator <*> : PromiseKApplicativePrecedence

infix operator >>-? : PromiseKMonadicPrecedenceLeft
infix operator -<<? : PromiseKMonadicPrecedenceRight
