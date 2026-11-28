// Generated from src/dsa/content/lessons/swift-optionals/swift-optional-map.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let pence: Int? = 1250

var pounds: Double? = nil
if let pence {
    pounds = Double(pence) / 100
}
print(pounds)
