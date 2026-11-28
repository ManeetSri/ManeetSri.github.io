// Generated from src/dsa/content/lessons/math-basics/math-probability.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func gcd(_ a: Int, _ b: Int) -> Int {
    b == 0 ? a : gcd(b, a % b)
}

func fraction(_ top: Int, _ bottom: Int) -> String {
    let g = gcd(top, bottom)
    return "\(top / g)/\(bottom / g)"
}

func permutations(_ items: [Int]) -> [[Int]] {
    if items.count <= 1 {
        return [items]
    }
    var result: [[Int]] = []
    for (i, item) in items.enumerated() {
        var rest = items
        rest.remove(at: i)
        for tail in permutations(rest) {
            result.append([item] + tail)
        }
    }
    return result
}

for n in 2...5 {
    let all = permutations(Array(0..<n))
    var stayed = 0
    for order in all {
        for i in 0..<n where order[i] == i {
            stayed += 1
        }
    }
    print(n, all.count, stayed, fraction(stayed, all.count))
}
