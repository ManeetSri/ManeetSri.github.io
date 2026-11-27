// Generated from src/dsa/content/lessons/swift-closures/swift-closure-syntax.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [5, 2, 9, 1]

// 1. A named function
func isGreater(_ a: Int, _ b: Int) -> Bool {
    return a > b
}
print(numbers.sorted(by: isGreater))

// 2. The full closure
print(numbers.sorted(by: { (a: Int, b: Int) -> Bool in
    return a > b
}))

// 3. Swift infers the types from sorted(by:)
print(numbers.sorted(by: { a, b in return a > b }))

// 4. A single expression returns its value automatically
print(numbers.sorted(by: { a, b in a > b }))

// 5. Shorthand argument names
print(numbers.sorted(by: { $0 > $1 }))

// 6. The operator itself is a function of the right type
print(numbers.sorted(by: >))
