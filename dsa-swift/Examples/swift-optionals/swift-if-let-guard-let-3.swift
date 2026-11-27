// Generated from src/dsa/content/lessons/swift-optionals/swift-if-let-guard-let.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let widthText = "12"
let heightText = "5"

if let width = Int(widthText), let height = Int(heightText), width > 0, height > 0 {
    print("Area: \(width * height)")
} else {
    print("Please enter two positive numbers")
}
