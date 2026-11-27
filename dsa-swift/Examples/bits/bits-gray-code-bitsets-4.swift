// Generated from src/dsa/content/lessons/bits/bits-gray-code-bitsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct BitSet64 {
    private(set) var bits: UInt64 = 0

    mutating func insert(_ x: Int) {
        precondition(0..<64 ~= x, "BitSet64 holds 0 to 63")
        bits |= 1 << x
    }

    mutating func remove(_ x: Int) {
        bits &= ~(1 << x)
    }

    func contains(_ x: Int) -> Bool {
        bits & (1 << x) != 0
    }

    var count: Int {
        bits.nonzeroBitCount
    }

    func sharesNothing(with other: BitSet64) -> Bool {
        bits & other.bits == 0
    }

    var elements: [Int] {
        var result: [Int] = []
        var rest = bits
        while rest != 0 {
            result.append(rest.trailingZeroBitCount)
            rest &= rest - 1
        }
        return result
    }
}

var set = BitSet64()
for x in [5, 0, 63, 17, 5] {
    set.insert(x)
}
print(set.elements, set.count, set.contains(17), set.contains(18))
set.remove(0)
print(set.elements)

func letters(of word: String) -> BitSet64 {
    var set = BitSet64()
    for character in word {
        if let ascii = character.asciiValue {
            set.insert(Int(ascii) - 97)
        }
    }
    return set
}

let words = ["swift", "array", "queue", "heap"]
let sets = words.map(letters(of:))
for i in 0..<words.count {
    for j in (i + 1)..<words.count where sets[i].sharesNothing(with: sets[j]) {
        print(words[i], words[j])
    }
}
