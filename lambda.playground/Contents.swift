enum Function {
    case none
    case literal(String)
    case function((Function) -> (Function))

    @discardableResult
    func eval() -> Function {
        return eval(.none)
    }

    @discardableResult
    func eval(_ arg: Function) -> Function {
        switch(self) {
        case .function(let function): return function(arg)
        case .literal(let literalString): print(literalString); return .none
        default: return .none
        }
    }
}

typealias Assertion = (String, Function) -> Void
typealias OneArgF   = (Function) -> Function
typealias TwoArgF   = (Function) -> (Function) -> Function
typealias ThreeArgF = (Function) -> (Function) -> (Function) -> Function

let ASSERT: Assertion  = { (id, statement) in statement.eval(.literal("[√] \(id)")).eval(.literal("[X] \(id)")).eval() }
let REFUTE: Assertion  = { (id, statement) in statement.eval(.literal("[X] \(id)")).eval(.literal("[√] \(id)")).eval() }

let IDENTITY:   Function  = .function { $0 }
let TRUE:       Function  = .function { x in .function { _ in x } }
let FALSE:      Function  = .function { _ in .function { y in y } }

let IFTHENELSE: ThreeArgF   = { test in { x in { y in test.eval(x).eval(y) } } }
let AND:        TwoArgF     = { x in { y in x.eval(y).eval(x) } }
let OR:         TwoArgF     = { x in { y in x.eval(x).eval(y) } }
let NOT:        OneArgF     = { x in x.eval(FALSE).eval(TRUE) }
let XOR:        TwoArgF     = { x in { y in x.eval(NOT(y)).eval(y) } }


ASSERT("identity", IDENTITY)

ASSERT("true", TRUE)
REFUTE("false", FALSE)

ASSERT("if (T) then else", IFTHENELSE(TRUE)(TRUE)(FALSE))
REFUTE("if (F) then else", IFTHENELSE(FALSE)(TRUE)(FALSE))

ASSERT("and (T T)", AND(TRUE)(TRUE))
REFUTE("and (T F)", AND(TRUE)(FALSE))
REFUTE("and (F T)", AND(FALSE)(TRUE))
REFUTE("and (F F)", AND(FALSE)(FALSE))

ASSERT("or (T T)", OR(TRUE)(TRUE))
ASSERT("or (T F)", OR(TRUE)(FALSE))
ASSERT("or (F T)", OR(FALSE)(TRUE))
REFUTE("or (F F)", OR(FALSE)(FALSE))

REFUTE("not (T)", NOT(TRUE))
ASSERT("not (F)", NOT(FALSE))

REFUTE("xor (T T)", XOR(TRUE)(TRUE))
ASSERT("xor (T F)", XOR(TRUE)(FALSE))
ASSERT("xor (F T)", XOR(FALSE)(TRUE))
REFUTE("xor (F F)", XOR(FALSE)(FALSE))

print("-----------------")

/*
 PEANO AXIOMS
 1. 0 is a natural number
 2. For every natural number x, x = x
 3. For all natural numbers x and y, if x = y, then y = x
 4. For all natural numbers x, y and z, if x = y and y = z, then x = z
 5. For all a and b. if b is a natural number and a = b, then a is also a natural number
 6. For every natural number n, S(n) is a natural number
 7. For all natural numbers m and n, m = n if and only if S(m) = S(n)
 8. For every natural number n, S(n) = 0 is false. That is no natural number whose successor is 0.
 */

let ZERO    = TRUE

let IS_ZERO:      OneArgF = { $0 }
let IS_NATURAL:   OneArgF = { _ in ZERO }
let EQUALS:       TwoArgF = { x in { y in IFTHENELSE(IS_ZERO(x))(IS_ZERO(y))(NOT(IS_ZERO(y))) } }
let SUCCESSOR:    OneArgF = { _ in FALSE }
let PREDECESSOR:  OneArgF = { _ in FALSE }

let ONE = SUCCESSOR(ZERO)
let TWO = SUCCESSOR(SUCCESSOR(ZERO))

// 1. 0 is natural
ASSERT("0", ZERO)
ASSERT("0 is natural", IS_NATURAL(ZERO))
ASSERT("0 is zero", IS_ZERO(ZERO))

// 2. x = x
ASSERT("x = x", EQUALS(ZERO)(ZERO))

// 2. x = x
// 7. m = n if and only if S(m) = S(n)
print("\nm = n iff S(m) = S(n)")
ASSERT("S(n) = S(n)", EQUALS(ONE)(ONE))
REFUTE("S(n) != n", EQUALS(ONE)(ZERO))
ASSERT("S(S(n)) = S(S(n))", EQUALS(TWO)(TWO))
REFUTE("S(S(n)) != S(n)", EQUALS(TWO)(ONE))
REFUTE("S(S(n)) != n", EQUALS(TWO)(ZERO))

// 8. there's no n which S(n) = 0
print("")
REFUTE("there's no n where S(n) = 0", IS_ZERO(SUCCESSOR(ZERO)))

print("\npredecessor")
REFUTE("P(0)", PREDECESSOR(ZERO))
ASSERT("P(S(0)) = 0", IS_ZERO(PREDECESSOR(ONE)))
ASSERT("P(S(n)) = n", EQUALS(PREDECESSOR(TWO))(ONE))

