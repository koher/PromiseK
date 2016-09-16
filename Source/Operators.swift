precedencegroup MonadicPrecedenceRight {
    associativity: right
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

precedencegroup MonadicPrecedenceLeft {
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

precedencegroup ApplicativePrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: NilCoalescingPrecedence
}

infix operator >>- : MonadicPrecedenceLeft
infix operator -<< : MonadicPrecedenceRight

infix operator <^> : ApplicativePrecedence
infix operator <*> : ApplicativePrecedence

infix operator >>-? : MonadicPrecedenceLeft
infix operator -<<? : MonadicPrecedenceRight
