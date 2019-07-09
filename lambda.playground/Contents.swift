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

let assertTrue: Assertion   = { (id, statement) in statement.eval(.literal("[√] \(id)")).eval(.literal("[X] \(id)")).eval() }
let assertFalse: Assertion  = { (id, statement) in statement.eval(.literal("[X] \(id)")).eval(.literal("[√] \(id)")).eval() }

let IDENTITY    = Function.function { $0 }
let TRUE        = Function.function { x in .function { _ in x } }
let FALSE       = Function.function { _ in .function { y in y } }

typealias OneArgF   = (Function) -> Function
typealias TwoArgF   = (Function) -> (Function) -> Function
typealias ThreeArgF = (Function) -> (Function) -> (Function) -> Function

let IFTHENELSE: ThreeArgF   = { test in { x in { y in test.eval(x).eval(y) } } }
let AND: TwoArgF            = { x in { y in x.eval(y).eval(x) } }
let OR: TwoArgF             = { x in { y in x.eval(x).eval(y) } }
let NOT: OneArgF            = { x in x.eval(FALSE).eval(TRUE) }
let XOR: TwoArgF            = { x in { y in x.eval(NOT(y)).eval(y) } }

assertTrue("identity", IDENTITY)

assertTrue("true", TRUE)
assertFalse("false", FALSE)

assertTrue("if then else (T)", IFTHENELSE(TRUE)(TRUE)(FALSE))
assertFalse("if then else (F)", IFTHENELSE(FALSE)(TRUE)(FALSE))

assertTrue("and (T T)", AND(TRUE)(TRUE))
assertFalse("and (T F)", AND(TRUE)(FALSE))
assertFalse("and (F T)", AND(FALSE)(TRUE))
assertFalse("and (F F)", AND(FALSE)(FALSE))

assertTrue("or (T T)", OR(TRUE)(TRUE))
assertTrue("or (T F)", OR(TRUE)(FALSE))
assertTrue("or (F T)", OR(FALSE)(TRUE))
assertFalse("or (F F)", OR(FALSE)(FALSE))

assertFalse("not (T)", NOT(TRUE))
assertTrue("not (F)", NOT(FALSE))

assertFalse("xor (T T)", XOR(TRUE)(TRUE))
assertTrue("xor (T F)", XOR(TRUE)(FALSE))
assertTrue("xor (F T)", XOR(FALSE)(TRUE))
assertFalse("xor (F F)", XOR(FALSE)(FALSE))

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

let ZERO = TRUE
let IS_NATURAL: OneArgF = { $0 }

assertTrue("zero", ZERO)
assertTrue("zero is natural", IS_NATURAL(ZERO))

