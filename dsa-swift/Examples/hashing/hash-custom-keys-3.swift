// Generated from src/dsa/content/lessons/hashing/hash-custom-keys.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var comparisons = 0

struct Plate: Hashable {
    let number: Int

    static func == (lhs: Plate, rhs: Plate) -> Bool {
        comparisons += 1
        return lhs.number == rhs.number
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(number)
    }
}

struct LazyPlate: Hashable {
    let number: Int

    static func == (lhs: LazyPlate, rhs: LazyPlate) -> Bool {
        comparisons += 1
        return lhs.number == rhs.number
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(0)             // every plate gets the same hash
    }
}

var good = Set<Plate>()
good.reserveCapacity(1_000)
for number in 0..<1_000 {
    good.insert(Plate(number: number))
}
print("good hash, under 5,000 comparisons:", comparisons < 5_000)

comparisons = 0
var lazy = Set<LazyPlate>()
lazy.reserveCapacity(1_000)
for number in 0..<1_000 {
    lazy.insert(LazyPlate(number: number))
}
print("constant hash:", comparisons, "comparisons")
