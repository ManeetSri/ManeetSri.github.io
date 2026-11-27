// Generated from src/dsa/content/lessons/swift-generics/swift-generic-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temporary = a
    a = b
    b = temporary
}

var x = 1
var y = 2
swapValues(&x, &y)
print(x, y)

var left = "L"
var right = "R"
swapValues(&left, &right)
print(left, right)
