// Generated from src/dsa/content/lessons/hashing/hash-collisions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let size = 7

func linear(_ key: Int, _ i: Int) -> Int {
    (key % size + i) % size
}

func quadratic(_ key: Int, _ i: Int) -> Int {
    (key % size + i * i) % size
}

func double(_ key: Int, _ i: Int) -> Int {
    let step = 1 + key % (size - 1)       // the second hash: 1 to 6, never 0
    return (key % size + i * step) % size
}

for key in [10, 17] {
    print("key \(key)")
    print("  linear:   ", (0..<size).map { linear(key, $0) })
    print("  quadratic:", (0..<size).map { quadratic(key, $0) })
    print("  double:   ", (0..<size).map { double(key, $0) })
}
