// Generated from src/dsa/content/lessons/recursion/rec-memo-preview.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Pair: Hashable {
    let n: Int
    let k: Int
}

var calls = 0

func choose(_ n: Int, _ k: Int) -> Int {
    calls += 1
    if k == 0 || k == n {
        return 1
    }
    return choose(n - 1, k - 1) + choose(n - 1, k)
}

func memoChoose(_ n: Int, _ k: Int) -> Int {
    var cache: [Pair: Int] = [:]

    func go(_ n: Int, _ k: Int) -> Int {
        calls += 1
        if k == 0 || k == n {
            return 1
        }
        if let known = cache[Pair(n: n, k: k)] {
            return known
        }
        let result = go(n - 1, k - 1) + go(n - 1, k)
        cache[Pair(n: n, k: k)] = result
        return result
    }

    return go(n, k)
}

calls = 0
print(choose(20, 10), "in", calls, "calls")
calls = 0
print(memoChoose(20, 10), "in", calls, "calls")
calls = 0
print(memoChoose(60, 30), "in", calls, "calls")
