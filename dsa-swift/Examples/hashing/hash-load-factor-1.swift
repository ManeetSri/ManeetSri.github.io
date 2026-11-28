// Generated from src/dsa/content/lessons/hashing/hash-load-factor.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var state: UInt64 = 2024
func scatteredHash() -> Int {              // a simple pseudo-random generator with a fixed start
    state = state &* 6364136223846793005 &+ 1442695040888963407
    return Int(state >> 33)
}

let size = 4_096
var taken = [Bool](repeating: false, count: size)
var count = 0

func probes(from start: Int) -> Int {      // slots examined to reach an empty one
    var index = start
    var examined = 1
    while taken[index] {
        index = (index + 1) % size
        examined += 1
    }
    return examined
}

for load in [0.5, 0.75, 0.9] {
    while Double(count) < load * Double(size) {     // fill up to this load
        var index = scatteredHash() % size
        while taken[index] {
            index = (index + 1) % size
        }
        taken[index] = true
        count += 1
    }
    var total = 0
    for _ in 0..<10_000 {                           // measure 10,000 lookups for missing keys
        total += probes(from: scatteredHash() % size)
    }
    print("load \(load): \(Double(total) / 10_000) slots per missing-key lookup")
}
