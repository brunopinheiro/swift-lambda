enum EFunction {
    case none
    case literal(String)
    case function((EFunction) -> (EFunction))

    func eval() -> EFunction {
        return eval(.none)
    }

    func eval(_ arg: EFunction) -> EFunction {
        switch(self) {
        case .function(let function): return function(arg)
        case .literal(let literalString): print(literalString); return .none
        default: return .none
        }
    }
}

let assertTrue = { (id: String, statement: EFunction) in statement.eval(.literal("[√] \(id)")).eval(.literal("[X] \(id)")).eval() }
let assertFalse = { (id: String, statement: EFunction) in statement.eval(.literal("[X] \(id)")).eval(.literal("[√] \(id)")).eval() }

let identity = { EFunction.function { $0 } }
let truth = { EFunction.function { x in EFunction.function { _ in x } } }
let falsy = { EFunction.function { _ in EFunction.function { y in y } } }
let ifThenElse = { (test: EFunction, x: EFunction, y: EFunction) in test.eval(x).eval(y) }
let and = { (x: EFunction, y: EFunction) in x.eval(y).eval(x) }

assertTrue("identity", identity())
assertTrue("true", truth())
assertFalse("false", falsy())

assertTrue("if then else (true)", ifThenElse(truth(), truth(), falsy()))
assertFalse("if then else (false)", ifThenElse(falsy(), truth(), falsy()))

assertTrue("and (true && true)", and(truth(), truth()))
assertFalse("and (true && false)", and(truth(), falsy()))
assertFalse("and (false && true)", and(falsy(), truth()))
assertFalse("and (false && false)", and(falsy(), falsy()))

print("[ ] or")
print("[ ] xor")
print("[ ] not")
