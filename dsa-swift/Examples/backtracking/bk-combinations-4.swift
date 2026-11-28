// Generated from src/dsa/content/lessons/backtracking/bk-combinations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func digitCombinations(count k: Int, sum target: Int) -> [[Int]] {
    var chosen: [Int] = []
    var result: [[Int]] = []
    var nodes = 0

    func explore(from start: Int, remaining: Int) {
        nodes += 1
        let need = k - chosen.count
        if need == 0 {
            if remaining == 0 { result.append(chosen) }
            return
        }
        if need * 9 - need * (need - 1) / 2 < remaining { return }   // 9 + 8 + … (need digits) can't reach it
        for digit in start..<10 {
            if need * digit + need * (need - 1) / 2 > remaining { break }   // digit + (digit + 1) + … overshoots
            chosen.append(digit)
            explore(from: digit + 1, remaining: remaining - digit)
            chosen.removeLast()
        }
    }

    explore(from: 1, remaining: target)
    print("  \(nodes) nodes")
    return result
}

print(digitCombinations(count: 3, sum: 9))
print(digitCombinations(count: 4, sum: 30))
