// Generated from src/dsa/content/lessons/dp-advanced/dpa-sos.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// How many pairs i < j have numbers[i] & numbers[j] == 0? Every number uses only the low `bits` bits.
func disjointPairs(_ numbers: [Int], bits n: Int) -> Int {
    let full = (1 << n) - 1
    var count = [Int](repeating: 0, count: 1 << n)
    for x in numbers { count[x] += 1 }
    // SOS: afterwards count[mask] = how many numbers are submasks of mask
    for bit in 0..<n {
        for mask in 0...full where mask & (1 << bit) != 0 {
            count[mask] += count[mask ^ (1 << bit)]
        }
    }
    var ordered = 0
    for x in numbers {
        ordered += count[full ^ x]                    // partners must avoid every bit of x
    }
    let zeros = numbers.filter { $0 == 0 }.count      // 0 & 0 == 0: each zero counted itself as a partner
    return (ordered - zeros) / 2                      // each pair was counted from both ends
}

func bruteForce(_ numbers: [Int]) -> Int {
    var pairs = 0
    for i in 0..<numbers.count {
        for j in (i + 1)..<numbers.count where numbers[i] & numbers[j] == 0 {
            pairs += 1
        }
    }
    return pairs
}

let numbers = [0b0011, 0b0100, 0b1000, 0b1100, 0b0001, 0b0000, 0b0110]
print(disjointPairs(numbers, bits: 4), bruteForce(numbers))
let many = (0..<2_000).map { ($0 * 7_919 + 13) % 1_024 }
print(disjointPairs(many, bits: 10), bruteForce(many))
