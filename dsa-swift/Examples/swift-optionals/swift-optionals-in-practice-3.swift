// Generated from src/dsa/content/lessons/swift-optionals/swift-optionals-in-practice.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let capitals = ["France": "Paris", "Japan": "Tokyo", "Kenya": "Nairobi"]

for country in ["Japan", "Peru"] {
    if let capital = capitals[country] {
        print("The capital of \(country) is \(capital)")
    } else {
        print("I don't know the capital of \(country)")
    }
}
