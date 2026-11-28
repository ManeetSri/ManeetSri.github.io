// Generated from src/dsa/content/lessons/randomised/rand-shuffle.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A seeded generator: any type with a mutating next() -> UInt64 can drive Swift's random APIs
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {          // SplitMix64: a fast, well-mixed 64-bit generator
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

let songs = ["Intro", "Rain", "Neon", "Drift", "Echo", "Coda"]

var first = SeededGenerator(seed: 42)
var second = SeededGenerator(seed: 42)
var other = SeededGenerator(seed: 7)

let a = songs.shuffled(using: &first)
let b = songs.shuffled(using: &second)
let c = songs.shuffled(using: &other)
print("same seed, same order:", a == b)
print("different seed, same order:", a == c)
print("still the same songs:", a.sorted() == songs.sorted())

// The same generator works for single random values too
var dice = SeededGenerator(seed: 1)
let rolls = (1...5).map { _ in Int.random(in: 1...6, using: &dice) }
var again = SeededGenerator(seed: 1)
let rollsAgain = (1...5).map { _ in Int.random(in: 1...6, using: &again) }
print("rolls repeat:", rolls == rollsAgain, "all in 1...6:", rolls.allSatisfy { (1...6).contains($0) })
