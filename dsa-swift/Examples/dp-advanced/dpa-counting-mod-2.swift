// Generated from src/dsa/content/lessons/dp-advanced/dpa-counting-mod.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mod = 1_000_000_007

// ways[t] = ways[t - 1] + … + ways[t - k]: the sum of a window, kept with a running prefix sum
func waysWithSteps(upTo k: Int, total n: Int) -> Int {
    var ways = [Int](repeating: 0, count: n + 1)
    var prefix = [Int](repeating: 0, count: n + 2)    // prefix[i] = ways[0] + … + ways[i - 1], reduced
    ways[0] = 1
    prefix[1] = 1
    for t in 1...n {
        let low = max(0, t - k)
        ways[t] = (prefix[t] - prefix[low] + mod) % mod   // the window sum; + mod keeps it non-negative
        prefix[t + 1] = (prefix[t] + ways[t]) % mod
    }
    return ways[n]
}

// The direct O(n · k) version, for checking
func waysDirect(upTo k: Int, total n: Int) -> Int {
    var ways = [Int](repeating: 0, count: n + 1)
    ways[0] = 1
    for t in 1...n {
        for step in 1...min(k, t) {
            ways[t] = (ways[t] + ways[t - step]) % mod
        }
    }
    return ways[n]
}

print(waysWithSteps(upTo: 6, total: 1_000), waysDirect(upTo: 6, total: 1_000))
print(waysWithSteps(upTo: 50, total: 2_000), waysDirect(upTo: 50, total: 2_000))
print(waysWithSteps(upTo: 100_000, total: 200_000))

// Without the + mod, a reduced prefix can be smaller than an earlier one, and the difference goes negative
let a = 1_000_000_010 % mod, b = 5
print(a - b, (a - b + mod) % mod)
