// Generated from src/dsa/content/lessons/problem-solving/algo-invariants.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func total(of numbers: [Int]) -> Int {
    var total = 0
    for i in 0..<numbers.count {
        assert(total == numbers[..<i].reduce(0, +), "invariant broken at pass \(i)")
        total += numbers[i]
    }
    return total
}

print(total(of: [4, 7, 1, 9]))
print(total(of: []))
