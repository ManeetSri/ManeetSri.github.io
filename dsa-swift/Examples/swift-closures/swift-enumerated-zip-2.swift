// Generated from src/dsa/content/lessons/swift-closures/swift-enumerated-zip.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let rolls = [3, 6, 2, 6, 6, 1]

let sixes = rolls.enumerated()
    .filter { $0.element == 6 }
    .map { $0.offset }
print(sixes)
