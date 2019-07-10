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

print("# logical operators")
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

print("\n# natural numbers")
let LIST:         TwoArgF = { head in { tail in .function { x in x.eval(head).eval(tail) } } }
let HEAD:         OneArgF = { $0.eval(TRUE) }
let TAIL:         OneArgF = { $0.eval(FALSE) }

let ZERO    = LIST(TRUE)(IDENTITY)

let IS_ZERO:      OneArgF = { HEAD($0) }
let SUCCESSOR:    OneArgF = { n in LIST(FALSE)(n) }
let PREDECESSOR:  OneArgF = { n in TAIL(n) }

// recurssion workaround
func EQUALS(_ x: Function) -> OneArgF {
    return { y in
        // lazy evaluation to avoid an infinity loop (.none is the flag)
        let partialResult = IFTHENELSE(IS_ZERO(x))(IS_ZERO(y))(IFTHENELSE(IS_ZERO(y))(FALSE)(.none))
        if case .none = partialResult { return EQUALS(PREDECESSOR(x))(PREDECESSOR(y)) }
        return partialResult
    }
}

let one = SUCCESSOR(ZERO)
let two = SUCCESSOR(SUCCESSOR(ZERO))

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

// 1. 0 is natural
ASSERT("0", ZERO)
ASSERT("0 is zero", IS_ZERO(ZERO))

// 2. x = x
ASSERT("x = x", EQUALS(ZERO)(ZERO))

// 2. x = x
// 7. m = n iff S(m) = S(n)
ASSERT("S(n) = S(n)", EQUALS(one)(one))
REFUTE("S(n) = 0", IS_ZERO(SUCCESSOR(ZERO)))
REFUTE("S(0) != 0", EQUALS(one)(ZERO))
REFUTE("S(n) != n", EQUALS(one)(two))
ASSERT("S(S(n)) = S(S(n))", EQUALS(two)(two))
REFUTE("S(S(n)) != S(n)", EQUALS(two)(one))
REFUTE("S(S(n)) != n", EQUALS(two)(ZERO))
REFUTE("P(0)", PREDECESSOR(ZERO).eval(FALSE))
ASSERT("P(S(0)) = 0", IS_ZERO(PREDECESSOR(one)))
ASSERT("P(S(n)) = n", EQUALS(PREDECESSOR(two))(one))

// 3. x = y -> y = x
let x = SUCCESSOR(ZERO)
let y = PREDECESSOR(SUCCESSOR(SUCCESSOR(ZERO)))
ASSERT("x = y, y = x", AND(EQUALS(x)(y))(EQUALS(y)(x)))

// 4. x = y, y = z -> x = z
let z = PREDECESSOR(SUCCESSOR(PREDECESSOR(SUCCESSOR(SUCCESSOR(ZERO)))))
ASSERT("x = y, y = z, x = z", AND(AND(EQUALS(x)(y))(EQUALS(y)(z)))(EQUALS(x)(z)))

print("\n# math operators (- division)")

extension Function {
    static func number(_ value: UInt) -> Function {
        return value == 0 ? ZERO : SUCCESSOR(number(value - 1))
    }
}

func ADD(_ x: Function) -> OneArgF {
    return { y in
        let partialResult = IFTHENELSE(IS_ZERO(x))(y)(.none)
        if case .none = partialResult { return ADD(PREDECESSOR(x))(SUCCESSOR(y)) }
        return partialResult
    }
}

ASSERT("add (0 + 4 = 4)", EQUALS(.number(4))(ADD(ZERO)(.number(4))))
ASSERT("add (3 + 4 = 7)", EQUALS(.number(7))(ADD(.number(3))(.number(4))))

func SUBTRACT(_ x: Function) -> OneArgF {
    return { y in
        let partialResult = IFTHENELSE(IS_ZERO(y))(x)((IFTHENELSE(IS_ZERO(x))(ZERO)(.none)))
        if case .none = partialResult { return SUBTRACT(PREDECESSOR(x))(PREDECESSOR(y)) }
        return partialResult
    }
}

ASSERT("subtract (3 - 0 = 3)", EQUALS(.number(3))(SUBTRACT(.number(3))(ZERO)))
ASSERT("subtract (5 - 3 = 2)", EQUALS(.number(2))(SUBTRACT(.number(5))(.number(3))))
ASSERT("subtract (3 - 5 = 0) uint", EQUALS(ZERO)(SUBTRACT(.number(3))(.number(5))))

func TIMES(_ x: Function) -> OneArgF {
    return { y in
        let partialResult = IFTHENELSE(IS_ZERO(x))(ZERO)((IFTHENELSE(IS_ZERO(y))(ZERO)(.none)))
        if case .none = partialResult { return ADD(x)(TIMES(x)(PREDECESSOR(y))) }
        return partialResult
    }
}

ASSERT("times (2 * 3 = 6)", EQUALS(.number(6))(TIMES(.number(2))(.number(3))))
ASSERT("times (4 * 0 = 0)", EQUALS(ZERO)(TIMES(.number(4))(ZERO)))
