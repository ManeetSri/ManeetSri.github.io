// Generated from src/dsa/content/lessons/swift-control-flow/swift-if-else.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 21

if n % 3 == 0 && n % 7 == 0 {
    print("\(n) is divisible by both 3 and 7")
} else if n % 3 == 0 || n % 7 == 0 {
    print("\(n) is divisible by one of them")
} else {
    print("\(n) is divisible by neither")
}
