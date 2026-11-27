// Generated from src/dsa/content/lessons/complexity/bigo-recurrences.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var work = 0

// T(n) = T(n/2) + 1
func halve(_ n: Int) {
    work += 1
    if n > 1 {
        halve(n / 2)
    }
}

// T(n) = 2T(n/2) + 1
func splitCheap(_ n: Int) {
    work += 1
    if n > 1 {
        splitCheap(n / 2)
        splitCheap(n / 2)
    }
}

// T(n) = 2T(n/2) + n
func splitAndScan(_ n: Int) {
    work += n
    if n > 1 {
        splitAndScan(n / 2)
        splitAndScan(n / 2)
    }
}

func measure(_ f: (Int) -> Void, _ n: Int) -> Int {
    work = 0
    f(n)
    return work
}

for n in [8, 64, 1_024] {
    print("n = \(n): halve \(measure(halve, n)), split cheap \(measure(splitCheap, n)), split and scan \(measure(splitAndScan, n))")
}
