// Generated from src/dsa/content/lessons/swift-optionals/swift-optionals-in-practice.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let samples = ["42", "-7", "+15", "007", "4.2", " 42", "", "12abc", "99999999999999999999"]

for text in samples {
    if let number = Int(text) {
        print("\"\(text)\" → \(number)")
    } else {
        print("\"\(text)\" → nil")
    }
}
