// Generated from src/dsa/content/lessons/swift-functions/swift-function-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func add(_ a: Int, _ b: Int) -> Int {
    a + b
}

func multiply(_ a: Int, _ b: Int) -> Int {
    a * b
}

var operation: (Int, Int) -> Int = add
print(operation(6, 3))

operation = multiply
print(operation(6, 3))
