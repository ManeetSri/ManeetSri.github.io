// Generated from src/dsa/content/lessons/swift-strings/swift-substring.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let line = "2024-06-15 ERROR disk full"
var dates: [String] = []

if let space = line.firstIndex(of: " ") {
    let date = line[..<space]
    dates.append(String(date))
}
print(dates)
