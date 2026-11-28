// Generated from src/dsa/content/lessons/arrays/arrays-memory.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Pixel {
    var red: UInt8
    var green: UInt8
    var blue: UInt8
}

print(MemoryLayout<Int>.stride)
print(MemoryLayout<Double>.stride)
print(MemoryLayout<Bool>.stride)
print(MemoryLayout<Pixel>.stride)
print(MemoryLayout<String>.stride)

let index = 1_000_000
print("element \(index) of an [Int] is \(index * MemoryLayout<Int>.stride) bytes past the base")
