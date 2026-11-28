// Generated from src/dsa/content/lessons/swift-functions/swift-argument-labels.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func move(from start: Int, to end: Int) {
    let distance = end - start
    print("Moving \(distance) steps from \(start) to \(end)")
}

move(from: 3, to: 10)
