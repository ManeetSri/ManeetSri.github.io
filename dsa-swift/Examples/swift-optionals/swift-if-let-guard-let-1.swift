// Generated from src/dsa/content/lessons/swift-optionals/swift-if-let-guard-let.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let input = "42"

if let number = Int(input) {
    print("You typed \(number). Doubled, that's \(number * 2).")
} else {
    print("\"\(input)\" isn't a whole number.")
}
