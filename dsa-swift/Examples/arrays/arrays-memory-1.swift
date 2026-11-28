// Generated from src/dsa/content/lessons/arrays/arrays-memory.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [10, 20, 30, 40]
numbers.withUnsafeBufferPointer { buffer in
    let base = Int(bitPattern: buffer.baseAddress!)
    for index in 0..<buffer.count {
        let address = Int(bitPattern: buffer.baseAddress! + index)
        print("element \(index) starts \(address - base) bytes after the base")
    }
}
