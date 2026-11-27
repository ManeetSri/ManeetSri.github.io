// Generated from src/dsa/content/lessons/swift-strings/swift-split-trim.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let title = "learn   swift today"
let slug = title.split(separator: " ").joined(separator: "-")
print(slug)

let capitalised = title.split(separator: " ").map { $0.prefix(1).uppercased() + $0.dropFirst() }
print(capitalised.joined(separator: " "))
