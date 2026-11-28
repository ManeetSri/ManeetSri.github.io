// Generated from src/dsa/content/lessons/design-structures/ds-randomized-set.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// A seeded generator (SplitMix64), so this example draws the same numbers every run
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

struct RandomizedSet<Element: Hashable> {
    private(set) var elements: [Element] = []      // packed, no holes: any index is an element
    private var positions: [Element: Int] = [:]    // where each element sits in `elements`

    @discardableResult
    mutating func insert(_ element: Element) -> Bool {
        guard positions[element] == nil else { return false }
        positions[element] = elements.count
        elements.append(element)
        return true
    }

    @discardableResult
    mutating func remove(_ element: Element) -> Bool {
        guard let hole = positions.removeValue(forKey: element) else { return false }
        let last = elements.removeLast()
        if hole < elements.count {                 // fill the hole with the old last element
            elements[hole] = last
            positions[last] = hole
        }
        return true
    }

    func randomElement<G: RandomNumberGenerator>(using generator: inout G) -> Element? {
        elements.randomElement(using: &generator)  // O(1): a random index into an array
    }
}

var songs = RandomizedSet<String>()
for song in ["Alpha", "Bravo", "Charlie", "Delta", "Echo"] {
    songs.insert(song)
}
print(songs.elements)
songs.remove("Bravo")                              // Echo moves into Bravo's slot
print(songs.elements)
songs.remove("Echo")                               // now Delta moves into slot 1
print(songs.elements)
songs.remove("Charlie")                            // the last slot: nothing moves
print(songs.elements)
print(songs.insert("Alpha"), songs.insert("Foxtrot"))
print(songs.elements)

var generator = SeededGenerator(seed: 42)
var tally: [String: Int] = [:]
for _ in 0..<30_000 {
    if let song = songs.randomElement(using: &generator) {
        tally[song, default: 0] += 1
    }
}
for song in tally.keys.sorted() {
    print(song, tally[song]!)
}
