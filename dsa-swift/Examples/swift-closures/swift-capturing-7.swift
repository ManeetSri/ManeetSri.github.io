// Generated from src/dsa/content/lessons/swift-closures/swift-capturing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var shared = 0
var printers: [() -> Void] = []

for _ in 1...3 {
    shared += 1
    printers.append { print("Shared \(shared)") }
}

for printer in printers {
    printer()
}
