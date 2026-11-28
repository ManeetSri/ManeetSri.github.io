// Generated from src/dsa/content/lessons/swift-optionals/swift-force-unwrap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let input = "seven"

// Safe options, each handling the nil case differently
if let n = Int(input) {
    print("if let: \(n)")
} else {
    print("if let: not a number")
}
print("?? gives \(Int(input) ?? 0)")
print("?. gives \(Int(input)?.description ?? "nil")")
