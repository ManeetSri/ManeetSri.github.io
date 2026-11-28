// Generated from src/dsa/content/lessons/swift-strings/swift-string-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let email = "maneet@example.com"
if let at = email.firstIndex(of: "@") {
    print(email[..<at])
    print(email[email.index(after: at)...])
    print(email.distance(from: email.startIndex, to: at))
}
