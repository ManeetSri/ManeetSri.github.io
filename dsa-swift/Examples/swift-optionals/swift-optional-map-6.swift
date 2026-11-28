// Generated from src/dsa/content/lessons/swift-optionals/swift-optional-map.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let ageText: String? = "17"

let message = ageText
    .flatMap { Int($0) }
    .map { $0 + 1 }
    .map { "Next year you'll be \($0)" }

print(message ?? "No valid age")
