// Generated from src/dsa/content/lessons/swift-library/lib-swift-algorithms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let steps = [4, 7, 5, 9, 12, 11]

// windows(ofCount: 3): every run of 3 neighbours, as slices
let windows = steps.indices.dropLast(2).map { steps[$0..<($0 + 3)] }
print(windows.map { $0.reduce(0, +) })

// chunks(ofCount: 4): consecutive groups of 4, the last one shorter
let chunks = stride(from: 0, to: steps.count, by: 4).map { steps[$0..<min($0 + 4, steps.count)] }
print(chunks.map(Array.init))

// adjacentPairs(): each element with the next one
let rises = zip(steps, steps.dropFirst()).map { $1 - $0 }
print(rises)

// striding(by: 2): every second element, starting with the first
print(stride(from: 0, to: steps.count, by: 2).map { steps[$0] })
