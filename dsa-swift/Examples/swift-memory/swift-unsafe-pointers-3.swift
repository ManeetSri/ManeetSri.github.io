// Generated from src/dsa/content/lessons/swift-memory/swift-unsafe-pointers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [3, 1, 4, 1, 5]

numbers.withUnsafeBufferPointer { buffer in
    if let base = buffer.baseAddress {
        print(base.pointee)
        print((base + 2).pointee)
        print(base[4])
    }
}
