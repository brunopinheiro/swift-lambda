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

assertTrue("identity", identity())
assertTrue("true", truth())
assertFalse("false", falsy())
print("[ ] if then else")
print("[ ] and")
print("[ ] or")
print("[ ] xor")
print("[ ] not")
