// Generated from src/dsa/content/lessons/swift-control-flow/swift-switch.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [7, 12, -3, 0]

for n in numbers {
    switch n {
    case 0:
        print("\(n) is zero")
    case let x where x < 0:
        print("\(x) is negative")
    case let x where x % 2 == 0:
        print("\(x) is even")
    default:
        print("\(n) is odd")
    }
}
