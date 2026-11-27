// Generated from src/dsa/content/lessons/swift-optionals/swift-nil-coalescing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let savedName: String? = nil
let displayName = savedName ?? "Guest"
print("Welcome, \(displayName)")

let typedAge = Int("29") ?? 0
let badAge = Int("old") ?? 0
print(typedAge, badAge)
