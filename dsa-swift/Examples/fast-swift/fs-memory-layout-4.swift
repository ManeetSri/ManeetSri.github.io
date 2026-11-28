// Generated from src/dsa/content/lessons/fast-swift/fs-memory-layout.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Particle {
    var x: Double
    var y: Double
    var z: Double
    var alive: Bool
}

let count = 1_000_000
print(MemoryLayout<Particle>.stride)
print("sum of x over [Particle] reads", count * MemoryLayout<Particle>.stride / 1_000_000, "MB")
print("sum of x over [Double] reads", count * MemoryLayout<Double>.stride / 1_000_000, "MB")
