// Generated from src/dsa/content/lessons/complexity/bigo-amortised.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func appendCost(_ n: Int) -> (growths: Int, copies: Int) {
    var numbers: [Int] = []
    var growths = 0
    var copies = 0
    for value in 0..<n {
        let oldCapacity = numbers.capacity
        let oldCount = numbers.count
        numbers.append(value)
        if numbers.capacity != oldCapacity {
            growths += 1
            copies += oldCount       // every existing element moved
        }
    }
    return (growths, copies)
}

for n in [100, 1_000, 10_000, 100_000] {
    let cost = appendCost(n)
    print("\(n) appends: \(cost.growths) growths, \(cost.copies) elements copied")
}
