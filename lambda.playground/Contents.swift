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

typealias TwoArgF   = (Function) -> (Function) -> Function
typealias ThreeArgF = (Function) -> (Function) -> (Function) -> Function

let IFTHENELSE: ThreeArgF   = { test in { x in { y in test.eval(x).eval(y) } } }
let AND: TwoArgF            = { x in { y in x.eval(y).eval(x) } }
let OR: TwoArgF             = { x in { y in x.eval(x).eval(y) } }

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

print("[ ] xor")
print("[ ] not")
