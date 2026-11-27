// Generated from src/dsa/content/lessons/swift-optionals/swift-optionals-in-practice.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let queue = ["Ana", "Ben", "Cleo", "Ben"]

print(queue.firstIndex(of: "Ben") ?? -1)
print(queue.lastIndex(of: "Ben") ?? -1)
print(queue.firstIndex(of: "Zoe") ?? -1)

if let position = queue.firstIndex(of: "Cleo") {
    print("Cleo is number \(position + 1) in the queue")
}
