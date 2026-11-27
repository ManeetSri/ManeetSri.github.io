// Generated from src/dsa/content/lessons/recursion/rec-memo-preview.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var calls = 0

func slowFib(_ n: Int) -> Int {
    calls += 1
    if n < 2 {
        return n
    }
    return slowFib(n - 1) + slowFib(n - 2)
}

var cache: [Int: Int] = [:]

func memoFib(_ n: Int) -> Int {
    calls += 1
    if n < 2 {
        return n
    }
    if let known = cache[n] {
        return known                       // answered before: no more calls
    }
    let result = memoFib(n - 1) + memoFib(n - 2)
    cache[n] = result                      // remember it for next time
    return result
}

calls = 0
print(slowFib(20), "in", calls, "calls")
calls = 0
print(memoFib(20), "in", calls, "calls")
