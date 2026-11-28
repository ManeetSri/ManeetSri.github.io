// Generated from src/dsa/content/lessons/two-pointers/tp-three-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func threeSumSlowly(_ numbers: [Int]) -> [[Int]] {
    var found = Set<[Int]>()
    let n = numbers.count
    for i in 0..<n {
        for j in (i + 1)..<n {
            for k in (j + 1)..<n where numbers[i] + numbers[j] + numbers[k] == 0 {
                found.insert([numbers[i], numbers[j], numbers[k]].sorted())
            }
        }
    }
    return found.sorted { $0.lexicographicallyPrecedes($1) }
}

print(threeSumSlowly([-2, 0, 1, 1, 2, -1, -4, 2]))
