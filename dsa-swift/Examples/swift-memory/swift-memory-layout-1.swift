// Generated from src/dsa/content/lessons/swift-memory/swift-memory-layout.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func describe<T>(_ type: T.Type, _ name: String) {
    let size = MemoryLayout<T>.size
    let stride = MemoryLayout<T>.stride
    let alignment = MemoryLayout<T>.alignment
    print("\(name): size \(size), stride \(stride), alignment \(alignment)")
}

describe(Int.self, "Int")
describe(Bool.self, "Bool")
describe(Double.self, "Double")
describe(Int32.self, "Int32")
describe(UInt8.self, "UInt8")
