// Generated from src/dsa/content/lessons/swift-collections/swift-array-basics.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let queue = [42, 17, 8]
let empty: [Int] = []

if let front = queue.first {
    print("First in line: \(front)")
}
print("Last in line: \(queue.last ?? -1)")
print("Empty array's first: \(empty.first ?? -1)")
