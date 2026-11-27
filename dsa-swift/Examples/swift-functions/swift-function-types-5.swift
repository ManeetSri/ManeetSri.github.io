// Generated from src/dsa/content/lessons/swift-functions/swift-function-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func operation(for symbol: Character) -> (Int, Int) -> Int {
    func add(_ a: Int, _ b: Int) -> Int { a + b }
    func subtract(_ a: Int, _ b: Int) -> Int { a - b }
    func multiply(_ a: Int, _ b: Int) -> Int { a * b }

    switch symbol {
    case "+": return add
    case "-": return subtract
    default: return multiply
    }
}

let chosen = operation(for: "-")
print(chosen(10, 4))
print(operation(for: "*")(10, 4))
