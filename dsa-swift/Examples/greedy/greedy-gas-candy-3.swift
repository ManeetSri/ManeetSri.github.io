// Generated from src/dsa/content/lessons/greedy/greedy-gas-candy.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fewestSweets(_ ratings: [Int]) -> Int {
    let n = ratings.count
    var left = Array(repeating: 1, count: n)
    for i in stride(from: 1, to: n, by: 1) where ratings[i] > ratings[i - 1] {
        left[i] = left[i - 1] + 1
    }
    var right = Array(repeating: 1, count: n)
    for i in stride(from: n - 2, through: 0, by: -1) where ratings[i] > ratings[i + 1] {
        right[i] = right[i + 1] + 1
    }
    let sweets = (0..<n).map { max(left[$0], right[$0]) }
    print("left  ", left)
    print("right ", right)
    print("sweets", sweets)
    return sweets.reduce(0, +)
}

print(fewestSweets([2, 4, 3, 2, 1, 3, 3]))
