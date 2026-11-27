// Generated from src/dsa/content/lessons/swift-memory/swift-unsafe-pointers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [3, 1, 4, 1, 5]

let total = numbers.withUnsafeBufferPointer { buffer -> Int in
    var sum = 0
    for i in 0..<buffer.count {
        sum += buffer[i]
    }
    return sum
}
print(total)
