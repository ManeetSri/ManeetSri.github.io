// Generated from src/dsa/content/lessons/swift-memory/swift-unsafe-pointers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var values = [1, 2, 3]
values.withUnsafeMutableBufferPointer { buffer in
    for i in buffer.indices {
        buffer[i] *= 10
    }
}
print(values)
