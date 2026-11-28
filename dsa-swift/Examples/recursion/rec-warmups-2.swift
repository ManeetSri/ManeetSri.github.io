// Generated from src/dsa/content/lessons/recursion/rec-warmups.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var calls = 0

func power(_ base: Int, _ exponent: Int) -> Int {
    calls += 1
    if exponent == 0 {
        return 1
    }
    return base * power(base, exponent - 1)
}

func fastPower(_ base: Int, _ exponent: Int) -> Int {
    calls += 1
    if exponent == 0 {
        return 1
    }
    let half = fastPower(base, exponent / 2)
    if exponent % 2 == 0 {
        return half * half
    }
    return half * half * base
}

calls = 0
print(power(2, 62), "in", calls, "calls")
calls = 0
print(fastPower(2, 62), "in", calls, "calls")
calls = 0
print(fastPower(3, 13), "in", calls, "calls")
