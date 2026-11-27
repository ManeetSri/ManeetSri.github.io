// Generated from src/dsa/content/lessons/swift-generics/swift-standard-protocols.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Priority: Comparable {
    case low, medium, high, urgent
}

let tasks: [Priority] = [.medium, .urgent, .low, .high]
print(tasks.max()!)
print(Priority.low < Priority.high)
for priority in tasks.sorted(by: >) {
    print(priority)
}
