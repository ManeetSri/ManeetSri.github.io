// Generated from src/dsa/content/lessons/swift-functions/swift-inout-swap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var a = 1
var b = 2

// With a temporary variable
let temp = a
a = b
b = temp
print(a, b)

// With a tuple: both values on the right are read before either is assigned
(a, b) = (b, a)
print(a, b)
