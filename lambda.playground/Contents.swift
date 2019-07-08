protocol Function {
    associatedtype Argument
    associatedtype Return
    func eval(_ arg: Argument) -> Return
}

class FunctionImpl<A, R>: Function {
    private let evaluation: (A) -> R
    init(_ evaluation: @escaping (A) -> R) { self.evaluation = evaluation }
    func eval(_ arg: A) -> R { return evaluation(arg) }
}

class StringLiteral: FunctionImpl<Any, String> {
    init(_ value: String) { super.init { (_) in value } }
    func eval() -> String { return eval(()) }
}

class Identity<A>: FunctionImpl<A, A> where A: Function {
    init() { super.init { (arg) in arg } }
}

class True<A, B>: FunctionImpl<A, FunctionImpl<B, A>> where A: Function, B: Function {
    init() { super.init { (x) in FunctionImpl<B, A> { (y) in x } } }
}

class False<A, B>: FunctionImpl<A, FunctionImpl<B, B>> where A: Function, B: Function {
    init() { super.init { (x) in FunctionImpl<B, B> { (y) in y } } }
}

func identity<A>(_ first: A) -> A where A: Function {
    return Identity<A>().eval(first)
}

func truth<A, B>(_ first: A, _ second: B) -> A where A: Function, B: Function {
    return True<A, B>().eval(first).eval(second)
}

func falsy<A, B>(_ first: A, _ second: B) -> B where A: Function, B: Function {
    return False<A, B>().eval(first).eval(second)
}

let pass = StringLiteral("√")
let fail = StringLiteral("X")

print("[\(identity(pass).eval())] identity")
print("[\(truth(pass, fail).eval())] true")
print("[\(falsy(fail, pass).eval())] false")
print("[ ] if then else")
print("[ ] and")
print("[ ] or")
print("[ ] xor")
print("[ ] not")
