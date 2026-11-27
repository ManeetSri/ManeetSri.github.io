// Generated from src/dsa/content/lessons/swift-memory/swift-unsafe-pointers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let pointer = UnsafeMutablePointer<Int>.allocate(capacity: 3)   // 1. get memory
pointer.initialize(repeating: 0, count: 3)                       // 2. put values in it
pointer[1] = 7
print(pointer[0], pointer[1], pointer[2])
pointer.deinitialize(count: 3)                                   // 3. destroy the values
pointer.deallocate()                                             // 4. give the memory back
