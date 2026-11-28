// Generated from src/dsa/content/lessons/swift-closures/swift-enumerated-zip.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let runners = ["Ada", "Ben", "Cleo"]

for (position, name) in runners.enumerated() {
    print("\(position + 1). \(name)")
}
