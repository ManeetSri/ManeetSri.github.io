// Generated from src/dsa/content/lessons/complexity/bigo-master-theorem.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var work = 0

// T(n) = a · T(n / 2) + n
func divide(_ n: Int, into a: Int) {
    work += n
    if n > 1 {
        for _ in 0..<a {
            divide(n / 2, into: a)
        }
    }
}

for n in [64, 256, 1_024] {
    var totals: [Int] = []
    for a in [1, 2, 4] {
        work = 0
        divide(n, into: a)
        totals.append(work)
    }
    print("n = \(n): a = 1 → \(totals[0]), a = 2 → \(totals[1]), a = 4 → \(totals[2])")
}
